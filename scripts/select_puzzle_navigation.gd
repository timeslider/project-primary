extends HBoxContainer

@onready var select_layout: SelectLayout = $"../SelectLayout"
@onready var select_players: SelectPlayers = $"../SelectPlayers"
@onready var select_goals: SelectGoals = $"../SelectGoals"

@onready var back_button: Button = $BackButton
@onready var help_button: Button = $HelpButton
@onready var next_button: Button = $NextButton

# Defaults to select layout
@onready var select_puzzle_manager: SelectPuzzleManager = %SelectPuzzleManager

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)


func _on_back_button_pressed():
	match select_puzzle_manager.select_puzzle_state:
		SelectPuzzleManager.SelectPuzzleStates.LAYOUT:
			# Go back to main menu
			select_layout.hide()
		SelectPuzzleManager.SelectPuzzleStates.PLAYERS:
			# Go to select layout
			select_players.hide()
			select_layout.show()
			select_puzzle_manager.select_puzzle_state = SelectPuzzleManager.SelectPuzzleStates.LAYOUT
		SelectPuzzleManager.SelectPuzzleStates.GOALS:
			# Go to select player
			select_goals.hide()
			select_players.show()
			select_puzzle_manager.select_puzzle_state = SelectPuzzleManager.SelectPuzzleStates.PLAYERS


# TODO: Design help panels
func _on_help_button_pressed():
	match select_puzzle_manager.select_puzzle_state:
		SelectPuzzleManager.SelectPuzzleStates.LAYOUT:
			# Show select help panel
			pass
		SelectPuzzleManager.SelectPuzzleStates.PLAYERS:
			# Show select player panel
			pass
		SelectPuzzleManager.SelectPuzzleStates.GOALS:
			# Show select goals panel
			pass


func _on_next_button_pressed():
	match select_puzzle_manager.select_puzzle_state:
		SelectPuzzleManager.SelectPuzzleStates.LAYOUT:
			# Go to select player
			select_layout.hide()
			select_players.show()
			select_puzzle_manager.select_puzzle_state = SelectPuzzleManager.SelectPuzzleStates.PLAYERS
			pass
		SelectPuzzleManager.SelectPuzzleStates.PLAYERS:
			# Go to select goals
			select_players.hide()
			select_goals.show()
			select_puzzle_manager.select_puzzle_state = SelectPuzzleManager.SelectPuzzleStates.GOALS
			pass
		SelectPuzzleManager.SelectPuzzleStates.GOALS:
			# Go to stage
			select_goals.hide()
			pass
