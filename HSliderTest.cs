using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Numerics;
using System.Runtime.InteropServices;
using Godot;
using static ProjectPrimary.Util;
using static ProjectPrimary.Bitboard;
using System.Linq;
using System.Threading.Tasks;

namespace ProjectPrimary
{
    public partial class HSliderTest : Node3D
    {
        private HSlider HSlider;
        private VSlider StartSlider;
        private VSlider EndSlider;
        
        private Button Increase;
        private Button Decrease;
        private Button Playable;
        private Button PopulateState;
        private Button Go;
        
        private TextEdit TextEditField;
        private Label PuzzleStatus;
        //private Bitboard bitboard;
        private ulong _nthPolyomino;
        private const ulong maxPolyomino = 51016818604894741UL;
        
        private PackedScene redTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/red-tile.blend");
        private PackedScene redGoal = (PackedScene)ResourceLoader.Load("res://Blender Meshes/red-goal.blend");
        private PackedScene yellowTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/yellow-tile.blend");
        private PackedScene yellowGoal = (PackedScene)ResourceLoader.Load("res://Blender Meshes/yellow-goal.blend");
        private PackedScene blueTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/blue-tile.blend");
        private PackedScene blueGoal = (PackedScene)ResourceLoader.Load("res://Blender Meshes/blue-goal.blend");
        private PackedScene groundTile = (PackedScene)ResourceLoader.Load("res://Blender Meshes/ground.blend");
        
        public List<Node> PlayerTiles = new List<Node>();
        public List<Node> GoalTiles = new List<Node>();
        public Node[,] GroundTiles = new Node[8, 8];

        private List<int> Solutions;

        Node3D yellowTileInstance;
        Node3D redTileInstance;
        Node3D blueTileInstance;

        Node3D redGoalInstance;
        Node3D yellowGoalInstance;
        Node3D blueGoalInstance;

        private int startIndex = 0;
        private int endIndex = 0;
        private Label startStateLabel;
        private Label endStateLabel;

        Tween tween;

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
        


        public override async void _Ready()
        {
            #region Spawn tiles
            SpawnDefaultStage();
            // Spawn player tiles off screen
            redTileInstance = (Node3D)redTile.Instantiate();
            yellowTileInstance = (Node3D)yellowTile.Instantiate();
            blueTileInstance = (Node3D)blueTile.Instantiate();

            GetNode("PlayerTiles").AddChild(redTileInstance);
            GetNode("PlayerTiles").AddChild(yellowTileInstance);
            GetNode("PlayerTiles").AddChild(blueTileInstance);

            redTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            yellowTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            blueTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);


            // Spawn goal tiles off screen
            redGoalInstance = (Node3D)redGoal.Instantiate();
            yellowGoalInstance = (Node3D)yellowGoal.Instantiate();
            blueGoalInstance = (Node3D)blueGoal.Instantiate();

            GetNode("Goals").AddChild(redGoalInstance);
            GetNode("Goals").AddChild(yellowGoalInstance);
            GetNode("Goals").AddChild(blueGoalInstance);

            redGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            yellowGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            blueGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            #endregion

            //GD.Print(Util.GetNValue(17925305085690880771));
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


            StartSlider = GetNode<VSlider>("StartSlider");
            //StartSlider.MaxValue = 0;
            //StartSlider.Editable = false;
            EndSlider = GetNode<VSlider>("EndSlider");
            //EndSlider.MaxValue = 0;
            //EndSlider.Editable = false;

            startStateLabel = GetNode<Label>("StartStateLabel");
            startStateLabel.Text = "-";

            endStateLabel = GetNode<Label>("EndStateLabel");
            endStateLabel.Text = "-";

            HSlider.MaxValue = maxPolyomino;
            //HSlider.MaxValue = 100;
            HSlider.Value = 0UL;
            NthPolyomino = (ulong)HSlider.Value;
            WallData = GetNthPolimyno(NthPolyomino);
            GetInitialState();
            Solutions = await StatesAsync();


            TransitionToNewPuzzle();
            GD.Print(HSlider.Value);
            HSlider.DragEnded += _on_h_slider_drag_ended;
            HSlider.ValueChanged += _on_h_slider_value_changed; // This is too slow, but I want to figure it out since it's more fun
            StartSlider.ValueChanged += UpdateStartStateLabel;
            EndSlider.ValueChanged += UpdateEndStateLabel;
            Increase.ButtonUp += _on_button_increase_up;
            Decrease.ButtonUp += _on_button_decrease_up;
            Playable.Pressed += _OnPlayablePress;
            Go.Pressed += _OnGoPressed;
            PopulateState.Pressed += UpdateStateLists;

        }

        public override void _Process(double delta)
        {
            
        }

        private void UpdateStartStateLabel(double value)
        {
            startStateLabel.Text = ((int)value).ToString();
            SetPlayerTiles((int)value);
        }


        private void UpdateEndStateLabel(double value)
        {
            endStateLabel.Text = ((int)value).ToString();
            SetGoals((int)value);
        }


        private void SpawnDefaultStage()
        {
            WallData = 0UL;
            for (int row = 0; row < 8; row++)
            {
                for (int col = 0; col < 8; col++)
                {
                    if (GetBitboardCell(WallData, col, row) == true)
                    {
                        Node3D groundTileInstance = (Node3D)groundTile.Instantiate();
                        GroundTiles[col, row] = groundTileInstance;
                        GetNode("Puzzle").AddChild(groundTileInstance);
                        groundTileInstance.GlobalPosition = new Godot.Vector3(col, 0.5f, row);
                    }
                    else
                    {
                        Node3D groundTileInstance = (Node3D)groundTile.Instantiate();
                        GroundTiles[col, row] = groundTileInstance;
                        GetNode("Puzzle").AddChild(groundTileInstance);
                        groundTileInstance.GlobalPosition = new Godot.Vector3(col, 0.0f, row);
                    }
                }
            }
        }

        private void SetGoals(int stateIndex)
        {
            //List<int> goals = new List<int>();
            //var goals = Solutions.Keys.ToList();
            SetState(Solutions[stateIndex]);
            redGoalInstance.GlobalPosition = new Godot.Vector3(Red % 8, 0.0f, Red / 8);
            yellowGoalInstance.GlobalPosition = new Godot.Vector3(Yellow % 8, 0.0f, Yellow / 8);
            blueGoalInstance.GlobalPosition = new Godot.Vector3(Blue % 8, 0.0f, Blue / 8);

        }
        private void SetPlayerTiles(int stateIndex)
        {
            //var players = Solutions.Keys.ToList();
            SetState(Solutions[stateIndex]);
            redTileInstance.Position = new Godot.Vector3(Red % 8, 0.0f, Red / 8);
            yellowTileInstance.GlobalPosition = new Godot.Vector3(Yellow % 8, 0.0f, Yellow / 8);
            blueTileInstance.GlobalPosition = new Godot.Vector3(Blue % 8, 0.0f, Blue / 8);
        }



        private void _OnGoPressed()
        {
            NthPolyomino = (ulong)Convert.ToInt64(TextEditField.Text);
            HSlider.Value = NthPolyomino;
        }

        private void _on_h_slider_drag_ended(bool value)
        {
            redTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            yellowTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            blueTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);

            redGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            yellowGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
            blueGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);

            NthPolyomino = (ulong)HSlider.Value;
            WallData = GetNthPolimyno(NthPolyomino);
            GetInitialState();
            TransitionToNewPuzzle();
            if (Bitboard.Playable == true)
            {
                PuzzleStatus.Text = "This puzzle is playable";
                PrintBitboard();
                //GD.Print(bitboard.StatesAsync().Count);
            }
            else
            {
                PuzzleStatus.Text = "This puzzle is NOT playable";
                GD.Print("This puzzle is NOT playable");
                foreach (var reason in Reasons)
                {
                    GD.Print(reason);
                }
            }
        }

        private void _on_h_slider_value_changed(double value)
        {

        }

        private void _on_button_increase_up()
        {
            if (NthPolyomino < maxPolyomino)
            {
                #region move tiles out of the way
                redTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                yellowTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                blueTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);

                redGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                yellowGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                blueGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                #endregion
                
                NthPolyomino += 1;
                HSlider.Value = NthPolyomino;
                WallData = GetNthPolimyno(NthPolyomino);
                //GetInitialState();
                TransitionToNewPuzzle();
                if (Bitboard.Playable == true)
                {
                    PuzzleStatus.Text = "This puzzle is playable";
                    PrintBitboard();
                    //GD.Print(bitboard.StatesAsync().Count);
                }
                else
                {
                    PuzzleStatus.Text = "This puzzle is NOT playable";
                    GD.Print("This puzzle is NOT playable");
                    foreach (var reason in Reasons)
                    {
                        GD.Print(reason);
                    }
                }
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
                #region move tiles out of the way
                redTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                yellowTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                blueTileInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);

                redGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                yellowGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                blueGoalInstance.GlobalPosition = new Godot.Vector3(100, 0, 0);
                #endregion
                
                NthPolyomino -= 1;
                HSlider.Value = NthPolyomino;
                WallData = GetNthPolimyno(NthPolyomino);
                //GetInitialState();
                TransitionToNewPuzzle();
                if (Bitboard.Playable == true)
                {
                    PuzzleStatus.Text = "This puzzle is playable";
                    PrintBitboard();
                    //GD.Print(bitboard.StatesAsync().Count);
                }
                else
                {
                    PuzzleStatus.Text = "This puzzle is NOT playable";
                    GD.Print("This puzzle is NOT playable");
                    foreach (var reason in Reasons)
                    {
                        GD.Print(reason);
                    }
                }
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

        private void _OnPlayablePress()
        {
            _ = HandlePlayablePressed();
        }

        private async Task HandlePlayablePressed()
        {

            WallData = GetNthPolimyno(NthPolyomino);
            CheckPlayable();
            GetInitialState();
            TransitionToNewPuzzle();


            if (Bitboard.Playable == true)
            {
                PuzzleStatus.Text = "This puzzle is playable";
                PrintBitboard();
                
                // Show loading here
                Solutions = await StatesAsync();
                // Hide loading here
                
                StartSlider.MaxValue = Solutions.Count - 1;
                EndSlider.MaxValue = Solutions.Count - 1;
                GD.Print(Solutions.Count);
            }
            else
            {
                PuzzleStatus.Text = "This puzzle is NOT playable";
                GD.Print("This puzzle is NOT playable");
                foreach (var reason in Reasons)
                {
                    GD.Print(reason);
                }
            }
        }

        private void TransitionToNewPuzzle()
        {
            CheckPlayable();
            Random random = new Random();

            if(tween != null)
            {
                tween.Kill();
            }
            for (int row = 0; row < 8; row++)
            {
                for (int col = 0; col < 8; col++)
                {
                    if (GetBitboardCell(WallData, col, row) == true)
                    {
                        tween = CreateTween();
                        tween.SetEase(Tween.EaseType.Out);
                        tween.SetTrans(Tween.TransitionType.Cubic);
                        tween.TweenProperty(GroundTiles[col, row], "position:y", 0.5, 0.5f);
                        //Tween.TweenProperty(GroundTiles[col, row], "", 1, 2);
                    }
                    else
                    {
                        tween = CreateTween();
                        tween.SetEase(Tween.EaseType.Out);
                        tween.SetTrans(Tween.TransitionType.Bounce);
                        tween.TweenInterval(random.NextDouble() * 0.25f);
                        tween.TweenProperty(GroundTiles[col, row], "position:y", 0.0, 0.5f);
                    }

                }
            }
        }

        private void UpdateStateLists()
        {

            var solutions = states;

            StartSlider.MaxValue = solutions.Count;
            GD.Print($"The solution count was {solutions.Count}");
            //StartSlider.Editable = true;
            EndSlider.MaxValue = solutions.Count;
            //EndSlider.Editable = true;
        }
    }
}
