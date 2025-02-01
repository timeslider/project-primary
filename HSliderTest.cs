using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Numerics;
using System.Runtime.InteropServices;
using Godot;
using static ProjectPrimary.Util;
using static ProjectPrimary.Bitboard;
using System.Linq;

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
		private TextEdit TextEditField;
		private Button Go;
		private Button PopulateState;
		private Label PuzzleStatus;
		private Bitboard bitboard;
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
		public Node[,] GroundTiles = new Node[8,8];

		private Dictionary<int, List<Direction>> Solutions;

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
			SpawnDefaultStage();
			// Spawn player tiles off screen
			yellowTileInstance = (Node3D)yellowTile.Instantiate();
			redTileInstance = (Node3D)redTile.Instantiate();
			blueTileInstance = (Node3D)blueTile.Instantiate();

			GetNode("PlayerTiles").AddChild(yellowTileInstance);
			GetNode("PlayerTiles").AddChild(redTileInstance);
            GetNode("PlayerTiles").AddChild(blueTileInstance);


            // Spawn goal tiles off screen
            redGoalInstance = (Node3D)redGoal.Instantiate();
            yellowGoalInstance = (Node3D)yellowGoal.Instantiate();
            blueGoalInstance = (Node3D)blueGoal.Instantiate();

            GetNode("Goals").AddChild(redGoalInstance);
			GetNode("Goals").AddChild(yellowGoalInstance);
			GetNode("Goals").AddChild(blueGoalInstance);

			redGoalInstance.GlobalPosition = new Godot.Vector3(0, 0, 0);
			yellowGoalInstance.GlobalPosition = new Godot.Vector3(0, 0, 0);
			blueGoalInstance.GlobalPosition = new Godot.Vector3(0, 0, 0);

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
			HSlider.Value = 49340209542762048UL;
			NthPolyomino = (ulong)HSlider.Value;
			bitboard = new Bitboard(GetNthPolimyno(NthPolyomino));

			

			TransitionToNewPuzzle(bitboard);
			GD.Print(HSlider.Value);
			HSlider.DragEnded += _on_h_slider_drag_ended;
			StartSlider.ValueChanged += UpdateStartStateLabel;
			EndSlider.ValueChanged += UpdateEndStateLabel;
			//HSlider.ValueChanged += _on_h_slider_value_changed; // This is too slow, but I want to figure it out since it's more fun
			Increase.ButtonUp += _on_button_increase_up;
			Decrease.ButtonUp += _on_button_decrease_up;
			Playable.Pressed += _OnPlayablePressed;
			Go.Pressed += _OnGoPressed;
			PopulateState.Pressed += UpdateStateLists;

		}

        //public override void _Process(double delta)
        //{
        //    throw new NotImplementedException();
        //}

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
			bitboard = new Bitboard(0UL);
            for (int row = 0; row < 8; row++)
            {
                for (int col = 0; col < 8; col++)
                {
                    if (GetBitboardCell(bitboard.WallData, col, row) == true)
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
			var goals = Solutions.Keys.ToList();
			bitboard.SetState(goals[stateIndex - 1]);
			redGoalInstance.GlobalPosition = new Godot.Vector3(bitboard.Red % 8, 0.0f, bitboard.Red / 8);
			yellowGoalInstance.GlobalPosition = new Godot.Vector3(bitboard.Yellow % 8, 0.0f, bitboard.Yellow / 8);
			blueGoalInstance.GlobalPosition = new Godot.Vector3(bitboard.Blue % 8, 0.0f, bitboard.Blue / 8);
            
		}
        private void SetPlayerTiles(int stateIndex)
        {
            var players = Solutions.Keys.ToList();
            bitboard.SetState(players[stateIndex - 1]);
               redTileInstance.Position = new Godot.Vector3(bitboard.Red    % 8, 0.0f, bitboard.Red    / 8);
            yellowTileInstance.GlobalPosition = new Godot.Vector3(bitboard.Yellow % 8, 0.0f, bitboard.Yellow / 8);
              blueTileInstance.GlobalPosition = new Godot.Vector3(bitboard.Blue   % 8, 0.0f, bitboard.Blue   / 8);
        }

		

        private void _OnGoPressed()
		{
			NthPolyomino = (ulong)Convert.ToInt64(TextEditField.Text);
			HSlider.Value = NthPolyomino;
		}

		private void _on_h_slider_drag_ended(bool value)
		{
			NthPolyomino = (ulong)HSlider.Value;
            bitboard.WallData = GetNthPolimyno(NthPolyomino);
            TransitionToNewPuzzle(bitboard);
            if (bitboard.Playable == true)
            {
                PuzzleStatus.Text = "This puzzle is playable";
                bitboard.PrintBitboard();
                //GD.Print(bitboard.Solutions().Count);
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
			bitboard.State = 0;
			bitboard = new Bitboard(GetNthPolimyno(NthPolyomino));
			TransitionToNewPuzzle(bitboard);
			if(bitboard.Playable == true)
			{
				PuzzleStatus.Text = "This puzzle is playable";
				bitboard.PrintBitboard();
				int maxCount = bitboard.Solutions().Count;
				StartSlider.MaxValue = maxCount;
				EndSlider.MaxValue = maxCount;
				Solutions = bitboard.Solutions();
                GD.Print(maxCount);
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

		private void TransitionToNewPuzzle(Bitboard bitboard)
		{
			Random random = new Random();
			
			for(int row = 0; row < 8; row++)
			{
				for(int col = 0; col < 8; col++)
				{
					if(GetBitboardCell(bitboard.WallData, col, row) == true)
					{
						var Tween = CreateTween();
						Tween.SetEase(Tween.EaseType.Out);
						Tween.SetTrans(Tween.TransitionType.Cubic);
						Tween.TweenProperty(GroundTiles[col, row], "position:y", 0.5, 2.0f);
						//Tween.TweenProperty(GroundTiles[col, row], "", 1, 2);
					}
					else
					{
						var Tween = CreateTween();
                        Tween.SetEase(Tween.EaseType.Out);
                        Tween.SetTrans(Tween.TransitionType.Bounce);
						Tween.TweenInterval(random.NextDouble() * 0.25f);
                        Tween.TweenProperty(GroundTiles[col, row], "position:y", 0.0, 0.5f);
					}

				}
			}
		}

		private void UpdateStateLists()
		{
			
			var solutions = bitboard.Solutions();
			
			StartSlider.MaxValue = solutions.Count;
			GD.Print($"The solution count was {solutions.Count}");
			//StartSlider.Editable = true;
			EndSlider.MaxValue = solutions.Count;
			//EndSlider.Editable = true;
		}
	}
}
