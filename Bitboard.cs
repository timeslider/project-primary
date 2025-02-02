using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Concurrent;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.X86;
using static ProjectPrimary.Util;
using static Godot.TextServer;
using Godot;
using System.Threading;

namespace ProjectPrimary
{
    internal static class Bitboard
    {
        // A ulong where the 1s represent where the walls are
        private static ulong wallData;
        public static ulong WallData { get { return wallData; } set { wallData = value; } }

        // If palyable is false, then this bitboard is not playable
        // In the future, I want to list the reasons it isn't playable
        // For now, the other reason is too few empty cells
        private static bool playable;
        public static bool Playable { get { return playable; } }
        private static List<string> reasons = new List<string>();
        public static List<string> Reasons
        {
            get {  return reasons; }
            private set {  reasons = value; }
        }


        // These represent the state
        // They represent where a colored tile is
        // They are 0-indexed and start at the top left and go left to right, top to bottom ending at the bottom right corner
        // They're eventually packed into 18-bit State variable where the first 6 bits are the red tile, the next 6 bits are yellow and the last 6 are blue
        private static int red = 0;
        public static int Red { get { return red; } }
        private static int yellow = 0;
        public static int Yellow { get { return yellow; } }
        private static int blue = 0;
        public static int Blue { get { return blue; } }


        // A merge of the colored tiles.
        // Defined by: state = red | (yellow << 6) | (blue << 12)
        public static int State { get { return GetState(); } }

        // The boundaries of the edges. Used to determine if crossing the solutionsList axis
        // Since a lot of indices goes from 0 to n -1 within an solutionsList, y plane we need a way to know when we have moved to another row
        private static readonly List<ulong> boundaries = new()
        {
            255,
            9259542123273814144,
            18374686479671623680,
            72340172838076673,
        };





        /// <summary>
        /// Represents a direction the state can try to move in
        /// </summary>
        public enum Direction
        {
            Up,
            Down,
            Left,
            Right,
        }


        ///// <summary>
        ///// Bitboards are always assumed to be 8 by 8
        ///// </summary>
        ///// <param name="bitboard">The wall data</param>
        //static Bitboard()
        //{
        //    //wallData = bitboard;
        //    CheckPlayable();
        //    //if (playable == true)
        //    //{
        //    //    GetInitialState();
        //    //}
        //    //if(wallData == 49340209542762048UL)
        //    //{
        //    //}
        //}




        /// <summary>
        /// Gets bitboard cell by index.
        /// Index starts at 0 in the top left corner and works its way left to right, top to bottom and ends at (sizeX * sizeY) - 1 in the bottom right.
        /// </summary>
        /// <param name="index">The index of the cell you're querring</param>
        /// <returns>A bool</returns>
        /// <exception cref="ArgumentOutOfRangeException">If index is less than 0 or greater than (sizeX * sizeY) - 1</exception>
        public static bool GetBitboardCell(int index)
        {
            ArgumentOutOfRangeException.ThrowIfNegative(index);
            ArgumentOutOfRangeException.ThrowIfGreaterThan(index, 63);
            return (wallData & (1UL << index)) != 0;
        }




        /// <summary>
        /// Get the value in the bitboard cell by (col, row) pair
        /// </summary>
        /// <param name="col">The col index of the bit that will be set</param>
        /// <param name="row">The row index of the bit that will be set</param>
        /// <returns>A bool</returns>
        public static bool GetBitboardCell(int col, int row)
        {
            // Just in case
            CheckBounds(col, row);

            int bitPosition = row * 8 + col;
            return (wallData & (1UL << bitPosition)) != 0;
        }




        /// <summary>
        /// Throws an error if col or row is out of bounds
        /// </summary>
        /// <param name="col"></param>
        /// <param name="row"></param>
        /// <param name="zeroIndexed">Defaults to true. Otherwise, assumes 1-indexed</param>
        /// <exception cref="ArgumentOutOfRangeException"></exception>
        private static void CheckBounds(int col, int row, bool zeroIndexed = true)
        {
            int lowIndex;
            int highIndex;
            if (zeroIndexed == true)
            {
                lowIndex = 0;
                highIndex = 7;
            }
            else
            {
                lowIndex = 1;
                highIndex = 8;
            }
            if (col < lowIndex)
            {
                throw new ArgumentOutOfRangeException("width was too small.");
            }
            if (row < lowIndex)
            {
                throw new ArgumentOutOfRangeException("height was too small.");
            }
            if (col > highIndex)
            {
                throw new ArgumentOutOfRangeException("width was too large");
            }
            if (row > highIndex)
            {
                throw new ArgumentOutOfRangeException("height was too large.");
            }
        }




        /// <summary>
        /// Returns the current state
        /// </summary>
        /// <returns>The current state</returns>
        public static int GetState()
        {
            return red | (yellow << 6) | (blue << 12);
        }




        /// <summary>
        /// Sets the red, yellow, and blue channels from an existing state
        /// </summary>
        /// <param name="existingState">An int where the first 18 bits are split into the 3 colors</param>
        public static void SetState(int existingState)
        {
            red = existingState & 0x3f;
            yellow = (existingState >> 6) & 0x3f;
            blue = (existingState >> 12) & 0x3f;
        }




        /// <summary>
        /// Prints the bitboard
        /// </summary>
        /// <param name="invert">Inverts the bitboard so 1s get displayed as 0s and visa versa</param>
        public static void PrintBitboard(bool invert = false)
        {
            StringBuilder sb = new StringBuilder();

            // Prints puzzle info so we always know which puzzle we are displaying
            sb.Append($"Puzzle: {wallData}, state: {State}\n");

            for (int row = 0; row < 8; row++)
            {
                for (int col = 0; col < 8; col++)
                {
                    if (row * 8 + col == red)
                    {
                        sb.Append("R ");
                        continue;
                    }
                    if (row * 8 + col == yellow)
                    {
                        sb.Append("Y ");
                        continue;
                    }

                    if (row * 8 + col == blue)
                    {
                        sb.Append("B ");
                        continue;
                    }

                    if (invert == true)
                    {
                        sb.Append(GetBitboardCell(col, row) ? "- " : "1 ");

                    }
                    else
                    {
                        sb.Append(GetBitboardCell(col, row) ? "1 " : "- ");
                    }
                }
                sb.Append('\n');
            }
            Console.WriteLine(sb.ToString());
            GD.Print(sb.ToString());
        }




        /// <summary>
        /// For a given board layout, finds where the starting tiles will go.
        /// Scanning left to right, top to bottom find the first empty cell and place a red tile.
        /// The remaining 2 colors should be attached to the red tile edge wise and their placement should create a minimum.
        /// </summary>
        public static void GetInitialState()
        {
            List<int> colors = new List<int>(3) { BitOperations.TrailingZeroCount(~wallData) };

            // Case 1: Move right
            if (CanMove(Direction.Right, colors[0]) > 0)
            {
                colors.Add(CanMove(Direction.Right, colors[0]));
                // Case 3: Move right
                if (CanMove(Direction.Right, colors[1]) > 0)
                {
                    colors.Add(CanMove(Direction.Right, colors[1]));
                }
                else if (CanMove(Direction.Down, colors[0]) > 0)
                {
                    colors.Add(CanMove(Direction.Down, colors[0]));
                }
                // Case 4: Move down
                else if (CanMove(Direction.Down, colors[1]) > 0)
                {
                    colors.Add(CanMove(Direction.Down, colors[1]));
                }
            }
            // Case 2: Move down
            else if (CanMove(Direction.Down, colors[0]) > 0)
            {
                colors.Add(CanMove(Direction.Down, colors[0]));
                // Case 5: Move left
                if (CanMove(Direction.Left, colors[1]) > 0)
                {
                    colors.Add(CanMove(Direction.Left, colors[1]));
                }
                // Case 6: Move right
                else if (CanMove(Direction.Right, colors[1]) > 0)
                {
                    colors.Add(CanMove(Direction.Right, colors[1]));
                }
                // Case 7: Move down
                else if (CanMove(Direction.Down, colors[1]) > 0)
                {
                    colors.Add(CanMove(Direction.Down, colors[1]));
                }
            }

            red = colors[0];
            yellow = Math.Min(colors[1], colors[2]);
            blue = Math.Max(colors[1], colors[2]);
            GD.Print($"Initial state was {State}");
        }




        public static void CheckPlayable()
        {
            // Empty cell count
            // Let the user define the minimum
            playable = true;
            int solutionCount = states.Count;
            if ((64 - BitOperations.PopCount(wallData)) < 4)
            {
                playable = false;
                Reasons.Add("There needs to be at least 4 empty holes in the bitboard.");
            }
            else if (solutionCount < 10) // This won't run if there are too few cells so it's ok
            {
                playable = false;
                Reasons.Add($"There were only {solutionCount} states.");
            }
        }




        /// <summary>
        /// Takes a direction and a current position
        /// Returns a new position if it can move
        /// Otherwise, it returns 0
        /// </summary>
        /// <param name="bitboard"></param>
        /// <param name="direction"></param>
        /// <param name="currentPosition"></param>
        /// <returns></returns>
        private static int CanMove(Direction direction, int currentPosition)
        {
            int directionVector = 0; // Where you are going to land
            int edge = 0;

            switch (direction)
            {
                case Direction.Right:
                    directionVector = currentPosition + 1;
                    edge = 1;
                    break;
                case Direction.Left:
                    directionVector = currentPosition - 1;
                    break;
                case Direction.Down:
                    directionVector = currentPosition + 8;
                    break;
                default:
                    break;
            }

            // The color's position would be larger than the size of the board
            if (directionVector > 64)
            {
                return 0;
            }

            // The direction is either left or right and you already on the edge
            if ((direction != Direction.Down && (currentPosition + edge) % 8 == 0))
            {
                return 0;
            }

            // A wall is there
            if (GetBitboardCell(directionVector) == true)
            {
                return 0;
            }

            // Red or Yellow already here
            if (directionVector == red)
            {
                return 0;
            }

            return directionVector;
        }




        /// <summary>
        /// Given a direction, return a new state with the direction applied
        /// </summary>
        /// <param name="direction">The direction to try to move in</param>
        /// <returns>A new state</returns>
        private static int MoveToNewState(Direction direction)
        {

            // Colors
            var colors = new List<(ulong bitboard, char name)>
            {
                (1UL << red, 'r'),
                (1UL << yellow, 'y'),
                (1UL << blue, 'b')
            };

            // Prevents us from reinitializing variables
            ulong boundary = 0UL;
            int moveDirection = 0;

            // Set up initial conditions
            switch (direction)
            {
                case Direction.Up:
                    boundary = boundaries[0];
                    moveDirection = 8;
                    colors.Sort();
                    break;
                case Direction.Right:
                    boundary = boundaries[1];
                    moveDirection = -1;
                    colors.Sort();
                    colors.Reverse();
                    break;
                case Direction.Down:
                    boundary = boundaries[2];
                    moveDirection = -8;
                    colors.Sort();
                    colors.Reverse();
                    break;
                case Direction.Left:
                    boundary = boundaries[3];
                    moveDirection = 1;
                    colors.Sort();
                    break;
                default:
                    break;
            }
            // It might be worth it to figure out which is most common and front load that
            for (int i = 0; i < colors.Count; i++)
            {
                if ((colors[i].bitboard & boundary) != 0) // Touching border already
                {
                    continue;
                }
                if (CheckOverlapColors(i, colors, moveDirection) == true) // Would have overlapped another tile
                {
                    continue;
                }

                if (((ShiftBitboardCell(colors[i].bitboard, moveDirection)) & wallData) != 0) // Would have overlapped a wall
                {
                    continue;
                }
                colors[i] = (ShiftBitboardCell(colors[i].bitboard, moveDirection), colors[i].name);
            }

            // Set the new state
            for (int i = 0; i < colors.Count; i++)
            {
                switch (colors[i].name)
                {
                    case 'r':
                        red = BitboardToIndex(colors[i].bitboard);
                        break;
                    case 'y':
                        yellow = BitboardToIndex(colors[i].bitboard);
                        break;
                    case 'b':
                        blue = BitboardToIndex(colors[i].bitboard);
                        break;
                }
            }

            return GetState();
        }




        /// <summary>
        /// Accepts a bitboard with a single bit and returns its index
        /// </summary>
        /// <param name="bitboard"></param>
        private static int BitboardToIndex(ulong bitboard)
        {
            if (BitOperations.PopCount(bitboard) != 1)
            {
                throw new ArgumentOutOfRangeException("Bitboard must contain exact 1 bit.");
            }
            // Convert single bit back into an index
            int bitPosition = BitOperations.TrailingZeroCount(bitboard);
            int row = bitPosition / 8;
            int col = bitPosition % 8;
            return row * 8 + col;
        }




        /// <summary>
        /// Checks if the color at position in colors[i] would overlap with another color in colors if it moved in 'moveDirection' .
        /// Since the colors are sorted, this might not be neccessary.
        /// </summary>
        /// <param name="i">The index of the color to check</param>
        /// <param name="colors">The rest of the colors</param>
        /// <param name="moveDirection">The direction we are trying to move</param>
        /// <returns></returns>
        private static bool CheckOverlapColors(int i, List<(ulong bitboard, char name)> colors, int moveDirection)
        {
            for (int j = 0; j < colors.Count; j++) // Check if the other tiles are here
            {
                if (j == i) // Don't check yourself
                {
                    continue;
                }
                ;
                if (((ShiftBitboardCell(colors[i].bitboard, moveDirection)) & (colors[j].bitboard)) != 0)
                {
                    return true;
                }
            }

            return false;
        }




        /// <summary>
        /// This lets us shift by a negative amount since you can't shift by a negative number
        /// </summary>
        /// <param name="bitboard">It assumes that bitboard has only 1 bit in it</param>
        /// <param name="shiftAmount">The amount to shift. Typical � 1 or � width</param>
        /// <returns>A bitboard with the bit shifted</returns>
        private static ulong ShiftBitboardCell(ulong bitboard, int shiftAmount)
        {
            if (shiftAmount > 0)
            {
                return bitboard >> shiftAmount;
            }
            else
            {
                return bitboard << -shiftAmount;
            }
        }




        public static List<int> states = new List<int>();
        /// <summary>
        /// Performs a BFS to find all the possible states of a given bitboard and inital starting state
        /// </summary>
        /// <TODO>There might be a simplier version of this on Claude.ai</TODO>
        /// <returns>A dictionary of type int, list where int is a new state and list contains all the moves needed to go from the inital state to the new state</returns>
        public static async Task<List<int>> StatesAsync()
        {

            return await Task.Run(() =>
            {
                GD.Print("StatesAsync method was ran again...");
                // Stores the states we have already visited
                var visited = new HashSet<int>();

                // Stores the states we need to visit
                var queue = new Queue<int>();

                // The output. The int is a new state and the List is a list of directions
                // If you start at the initial state and follow the directions, you'll end up at the new state
                states.Clear();

                // Get initial state and add to data structures
                GetInitialState();
                GD.Print("This is the initial state");
                PrintBitboard();
                queue.Enqueue(GetState());
                visited.Add(GetState());
                states.Add(GetState());

                while (queue.Count > 0)
                {
                    var currentState = queue.Dequeue();

                    // Set the board to current state once before trying directions
                    SetState(currentState);

                    foreach (Direction direction in Enum.GetValues(typeof(Direction)))
                    {
                        int newState = MoveToNewState(direction);

                        if (!visited.Contains(newState))
                        {
                            visited.Add(newState);
                            queue.Enqueue(newState);
                            states.Add(newState);
                        }

                        // Reset to current state before trying colors direction
                        SetState(currentState);
                    }
                }
                SetState(states[0]);
                GD.Print($"This is state[0]. There are {states.Count} states.");
                PrintBitboard();
                return states;
            });
        }
    }
}
