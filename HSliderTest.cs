using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;
using static ProjectPrimary.Util;

namespace ProjectPrimary
{
    public partial class HSliderTest : Node3D
    {
        private HSlider HSlider;
        private Button Increase;
        private Button Decrease;
        private Button Playable;
        private TextEdit TextEditField;
        private Button Go;
        private Button PopulateState;
        private Label PuzzleStatus;
        private Bitboard bitboard;
        private ulong _nthPolyomino;
        private const ulong maxPolyomino = 51016818604894741UL;
        public ulong NthPolyomino
        {
            get { return _nthPolyomino; }

            set
            {
                if (value < 0)
                {
                    _nthPolyomino = 0;
                    GD.Print("Value was less than 0");
                }
                else if (value > maxPolyomino)

                {
                    _nthPolyomino = maxPolyomino;
                    GD.Print($"Value was greater than {maxPolyomino}.");
                }
                else
                {
                    _nthPolyomino = value;
                    GD.Print($"Value was {value}");
                }
            }
        }


        public override void _Ready()
        {
            int startState = Util.ExpandState("00000000", (byte)0xFF);
            Util.MakeGenState(0, startState, 0);
            GD.Print($"Gen state number: {Util.genStateNumbers.Count}");
            HSlider = GetNode<HSlider>("HSlider");
            Increase = GetNode<Button>("Increase");
            Decrease = GetNode<Button>("Decrease");
            PuzzleStatus = GetNode<Label>("Button/Label");
            Go = GetNode<Button>("Button");
            PopulateState = GetNode<Button>("Button2");
            TextEditField = GetNode<TextEdit>("Button/TextEdit");
            Playable = GetNode<Button>("Playable");
            HSlider.MaxValue = maxPolyomino;
            HSlider.Value = 49340209542762048UL;
            NthPolyomino = (ulong)HSlider.Value;
            bitboard = new Bitboard(GetNthPolimyno(NthPolyomino));
            LoadPuzzle(bitboard);
            GD.Print(HSlider.Value);
            HSlider.DragEnded += _on_h_slider_drag_ended;
            Increase.ButtonUp += _on_button_increase_up;
            Decrease.ButtonUp += _on_button_decrease_up;
            Playable.Pressed += _OnPlayablePressed;
            Go.Pressed += _OnGoPressed;
            PopulateState.Pressed += UpdateStateLists;
        }

        private void _OnGoPressed()
        {
            NthPolyomino = (ulong)Convert.ToInt64(TextEditField.Text);
            HSlider.Value = NthPolyomino;
        }

        private void _on_h_slider_drag_ended(bool value)
        {
            NthPolyomino = (ulong)HSlider.Value;
            _UpdateConsole();
        }

        private void _on_button_increase_up()
        {
            if (NthPolyomino < maxPolyomino)
            {
                NthPolyomino += 1;
                HSlider.Value = NthPolyomino;
                _UpdateConsole();
            }
            else
            {
                GD.Print($"NthPolyomino was {maxPolyomino}. Not updating.");
            }
        }

        private void _on_button_decrease_up()
        {
            if (NthPolyomino > 0)
            {
                NthPolyomino -= 1;
                HSlider.Value = NthPolyomino;
                _UpdateConsole();
            }
            else
            {
                GD.Print("NthPolyomino was 0. Not updating.");
            }
        }

        private void _UpdateConsole()
        {

            GD.Print($"NthPolyomino: {NthPolyomino}");
            Util.PrintBitboard(Util.GetNthPolimyno(NthPolyomino));
        }

        private void _OnPlayablePressed()
        {
            bitboard = new Bitboard(GetNthPolimyno(NthPolyomino));
            LoadPuzzle(bitboard);
            if(bitboard.Playable == true)
            {
                PuzzleStatus.Text = "This puzzle is playable";
                bitboard.PrintBitboard();
                GD.Print(bitboard.Solutions().Count);
            }
            else
            {
                PuzzleStatus.Text = "This puzzle is NOT playable";
                GD.Print("This puzzle is NOT playable");
                foreach (var reason in bitboard.Reasons)
                {
                    GD.Print(reason);
                }
            }
        }

        private void LoadPuzzle(Bitboard bitboard)
        {

            // Clear existing

            foreach(var child in GetNode("Puzzle").GetChildren())
            {
                child.Free();
            }

            var redTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/red-tile.blend");
            var yellowTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/yellow-tile.blend");
            var blueTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/blue-tile.blend");
            var groundTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/ground.blend");

            //AddChild(instance);
            //if(instance is Node3D instance3D)
            //{
            //    instance3D.Position = new Vector3(0, 0, 0);
            //}

            for(int row = 0; row < 8; row++)
            {
                for(int col = 0; col < 8; col++)
                {
                    if(GetBitboardCell(bitboard.WallData, col, row) == true)
                    {
                        Node3D groundTileInstance = (Node3D)groundTile.Instantiate();
                        GetNode("Puzzle").AddChild(groundTileInstance);
                        groundTileInstance.GlobalPosition = new Vector3(col, 0.5f, row);
                    }
                    else
                    {
                        Node3D groundTileInstance = (Node3D)groundTile.Instantiate();
                        GetNode("Puzzle").AddChild(groundTileInstance);
                        groundTileInstance.GlobalPosition = new Vector3(col, 0.0f, row);
                    }

                    if(row * 8 + col == bitboard.Red)
                    {
                        Node3D redTileInstance = (Node3D)redTile.Instantiate();
                        GetNode("Puzzle").AddChild(redTileInstance);
                        redTileInstance.GlobalPosition = new Vector3(col, 0.25f, row);
                    }

                    if (row * 8 + col == bitboard.Yellow)
                    {
                        Node3D yellowTileInstance = (Node3D)yellowTile.Instantiate();
                        GetNode("Puzzle").AddChild(yellowTileInstance);
                        yellowTileInstance.GlobalPosition = new Vector3(col, 0.25f, row);
                    }

                    if (row * 8 + col == bitboard.Blue)
                    {
                        Node3D blueTileInstance = (Node3D)blueTile.Instantiate();
                        GetNode("Puzzle").AddChild(blueTileInstance);
                        blueTileInstance.GlobalPosition = new Vector3(col, 0.25f, row);
                    }

                }
            }
        }

        private void UpdateStateLists()
        {
            var startState = GetNode<VBoxContainer>("StartState/VBoxContainer");
            GD.Print("Populating state");

            var solutions = bitboard.Solutions();
            // Clear existing lists
            foreach (var child in startState.GetChildren())
            {
                child.Free();
            }
            int i = 0;
            foreach(var solution in solutions)
            {
                //if(i == 10)
                //{
                //    break;
                //}
                Button button = new Button();
                button.Text = $"{solution.Key}";
                startState.AddChild(button);
                i++;
            }
        }
    }
}

