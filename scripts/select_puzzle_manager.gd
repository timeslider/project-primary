class_name SelectPuzzleManager
extends MarginContainer

@onready var select_layout: SelectLayout = $VBoxContainer/SelectLayout
@onready var select_players: SelectPlayers = $VBoxContainer/SelectPlayers
@onready var select_goals: SelectGoals = $VBoxContainer/SelectGoals

enum SelectPuzzleStates {
	LAYOUT,
	PLAYERS,
	GOALS
}

## This represents the current state of the select puzzle menu
@export var select_puzzle_state: SelectPuzzleStates
