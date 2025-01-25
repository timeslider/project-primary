using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Security;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.X86;
using System.Text;

namespace ProjectPrimary
{
    public partial class Util : Node
    {
        public struct GenTransitionInfo
        {
            public byte nextRow;
            public ushort nextState;
            public ulong cumulativePaths;
        }

        /// <summary>
        /// checker_state + next_row_number * 4096 + have_islands*65536 -> generator_state
        /// </summary>
        public static Dictionary<int, ushort> genStateNumbers = new Dictionary<int, ushort>();
        
        
        /// <summary>
        /// Generator states.  These for a DFA that accepts all 8-row polyminoes.
        /// State 0 is used as both the unique start state and the unique accept state
        /// </summary>
        public static List<List<GenTransitionInfo>> genStates = new List<List<GenTransitionInfo>>();


        /// <summary>
        /// Map from the long-form state code for each state to the state number
        /// see expandState.
        /// 
        /// This is only used during state table construction.
        /// </summary>
        public static Dictionary<string, ushort> stateNumbers = new Dictionary<string, ushort>();


        /// <summary>
        /// Packed map from (state*256 + next_row_byte) -> transition
        /// 
        /// transition is next_state + (island_count<<12), where island_count is the
        /// number of islands cut off from the further rows
        /// </summary>
        public static List<ushort> transitions = new List<ushort>();


        /// <summary>
        /// The byte representing a row of all water.  Note that this code counts
        /// 0-islands, not 1-islands
        /// </summary>
        public const byte ALL_WATER = (byte)0xFF;


        /// <summary>
        /// Fill out a state in the generator table if it doesn't exist
        /// Return the state number
        /// </summary>
        public static ushort MakeGenState(int nextRowNumber, int checkerState, int haveIslands)
        {
            int stateKey = checkerState + nextRowNumber * 4096 + haveIslands * 65536;
            if (genStateNumbers.ContainsKey(stateKey))
            {
                return genStateNumbers[stateKey];
            }
            ushort newGenState = (ushort)genStates.Count;
            genStateNumbers.Add(stateKey, newGenState);
            var tlist = new List<GenTransitionInfo>();
            genStates.Add(tlist);
            int transitionsOffset = checkerState * 256;
            ulong totalPaths = 0;
            for (int i = 0; i < 256; ++i)
            {
                var transition = transitions[transitionsOffset + i];
                int nextCheckerState = transition & 0x0FFF;
                var newIslands = (transition >> 12) + haveIslands;
                if (newIslands > (i == ALL_WATER ? 1 : 0))
                {
                    // we are destined to get too many islands this way.
                    continue;
                }
                if (nextRowNumber == 7)
                {
                    // all transitions for row 7 have to to the accept state
                    // calculate total number of islands
                    newIslands += transitions[nextCheckerState * 256 + ALL_WATER] >> 12;
                    if (newIslands == 1)
                    {
                        totalPaths += 1;
                        tlist.Add(new GenTransitionInfo
                        {
                            nextRow = (byte)i,
                            nextState = 0,
                            cumulativePaths = totalPaths
                        });
                    }
                }
                else
                {
                    ushort nextGenState = MakeGenState(nextRowNumber + 1, nextCheckerState, newIslands);
                    ulong newPaths = genStates[nextGenState].LastOrDefault().cumulativePaths;
                    if (newPaths > 0)
                    {
                        totalPaths += newPaths;
                        tlist.Add(new GenTransitionInfo
                        {
                            nextRow = (byte)i,
                            nextState = nextGenState,
                            cumulativePaths = totalPaths
                        });
                    }
                }
            }
            return newGenState;
        }

        public static ulong GetNthPolimyno(ulong n)
        {
            int state = 0;
            ulong poly = 0;
            for (int row = 0; row < 8; ++row)
            {
                var tlist = genStates[state];
                // binary search to find the transition that contains the nth path
                int hi = tlist.Count - 1;
                int lo = 0;
                while (hi > lo)
                {
                    int test = (lo + hi) >> 1;
                    if (n >= tlist[test].cumulativePaths)
                    {
                        // test is too low
                        lo = test + 1;
                    }
                    else
                    {
                        // test is high enough
                        hi = test;
                    }
                }
                if (lo > 0)
                {
                    n -= tlist[lo - 1].cumulativePaths;
                }
                var transition = tlist[lo];
                poly = (poly << 8) | transition.nextRow;
                state = transition.nextState;
            }
            return poly;
        }







        /// <summary>
        /// Expands the specified state code.
        /// 
        /// A state code is a string of digits.
        ///  0 => water
        ///  x => island number x.  new islands are numbered from left to right
        /// </summary>
        /// <param name="stateCode">The state code to expand.</param>
        /// <param name="nextrow">the lower 8 bits represent the next row.  0-bits are land</param>
        /// <returns>The transition code for the transition from stateCode to nextrow</returns>
        public static ushort ExpandState(string stateCode, int nextrow)
        {
            // convert the next row into a disjoint set array
            // if you want to count 1-islands instead of 0-islands, change `~nextrow` into `nextrow` below,
            // and fix the ALL_WATER constant
            int[] sets = new int[8];
            for (int i = 0; i < 8; ++i)
            {
                sets[i] = (~nextrow >> i) & 1;
            }
            for (int i = 0; i < 7; ++i)
            {
                if (((~nextrow >> i) & 3) == 3)
                {
                    union(sets, i, i + 1);
                }
            }
            // map from state code island to first attached set in sets
            int[] links = [-1, -1, -1, -1, -1, -1, -1, -1];
            int topIslandCount = 0;
            for (int i = 0; i < 8; ++i)
            {
                char digit = stateCode[i];
                int topisland = digit - '1';
                topIslandCount = Math.Max(topIslandCount, topisland + 1);
                if (sets[i] != 0 && topisland >= 0)
                {
                    // connection from prev row to nextrow
                    int bottomSet = links[topisland];
                    if (bottomSet < 0)
                    {
                        // this island is not yet connected
                        links[topisland] = i;
                    }
                    else
                    {
                        // the top island is already connected. union bottom sets
                        union(sets, bottomSet, i);
                    }
                }
            }

            // count the number of top-row islands that don't connect to the next row.
            int cutOffCount = 0;
            for (int i = 0; i < topIslandCount; ++i)
            {
                if (links[i] < 0)
                {
                    ++cutOffCount;
                }
            }

            // turn the new union-find array into a state code
            char nextSet = '1';
            char[] newChars = "00000000".ToCharArray();
            for (int i = 0; i < 8; ++i)
            {
                links[i] = -1;
            }
            for (int i = 0; i < 8; ++i)
            {
                if (sets[i] != 0)
                {
                    int set = find(sets, i);
                    int link = links[set];
                    if (link >= 0)
                    {
                        newChars[i] = newChars[link];
                    }
                    else
                    {
                        newChars[i] = nextSet++;
                        links[set] = i;
                    }
                }
            }
            string newStateCode = new string(newChars);

            // get the state number
            if (stateNumbers.ContainsKey(newStateCode))
            {
                // state already exists and is/will be expanded
                return (ushort)(stateNumbers[newStateCode] | (cutOffCount << 12));
            }
            ushort newState = (ushort)stateNumbers.Count;
            stateNumbers.Add(newStateCode, newState);

            // fill out the state table
            while (transitions.Count <= (newState + 1) * 256)
            {
                transitions.Add(0);
            }
            for (int i = 0; i < 256; ++i)
            {
                transitions[newState * 256 + i] = ExpandState(newStateCode, i);
            }
            return (ushort)(newState | (cutOffCount << 12));
        }





        // union by size
        private static bool union(int[] sets, int x, int y)
        {
            x = find(sets, x);
            y = find(sets, y);
            if (x == y)
            {
                return false;
            }
            int szx = sets[x];
            int szy = sets[y];
            if (szx < szy)
            {
                sets[y] += szx;
                sets[x] = ~y;
            }
            else
            {
                sets[x] += szy;
                sets[y] = ~x;
            }
            return true;
        }






        /// <summary>
        /// 
        /// </summary>
        /// <param name="sets"></param>
        /// <param name="s"></param>
        /// <returns></returns>
        private static int find(int[] sets, int s)
        {
            int parent = sets[s];
            if (parent > 0)
            {
                return s;
            }
            else if (parent < 0)
            {
                parent = find(sets, ~parent);
                sets[s] = ~parent;
                return parent;
            }
            else
            {
                sets[s] = 1;
                return s;
            }
        }


        /// <summary>
        /// Gets the value of the bool at position (x, y)
        /// </summary>
        /// <param name="bitBoard">The bitboard to query.</param>
        /// <param name="col">The 0-indexed column value.</param>
        /// <param name="row">The 0-indexed row value.</param>
        /// <returns></returns>
        public static bool GetBitboardCell(ulong bitBoard, int col, int row)
        {

            int bitPosition = row * 8 + col;
            return (bitBoard & (1UL << bitPosition)) != 0;
        }




        /// <summary>
        /// 
        /// </summary>
        /// <param name="bitBoard"></param>
        /// <param name="invert"></param>
        public static void PrintBitboard(ulong bitBoard, bool invert = false)
        {
            StringBuilder sb = new StringBuilder();

            // Prints the puzzle ID so we always know which puzzle we are displaying
            sb.Append(bitBoard + "\n");

            for (int row = 0; row < 8; row++)
            {
                for (int col = 0; col < 8; col++)
                {
                    if (invert == true)
                    {
                        if (GetBitboardCell(bitBoard, col, row) == true)
                        {
                            sb.Append("- ");
                        }
                        else
                        {
                            sb.Append("1 ");
                        }
                    }
                    else
                    {
                        if (GetBitboardCell(bitBoard, col, row) == true)
                        {
                            sb.Append("1 ");
                        }
                        else
                        {
                            sb.Append("- ");
                        }
                    }
                }
                sb.Append('\n');
            }
            GD.Print(sb.ToString());
        }
    }
}

