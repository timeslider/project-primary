extends Node

## This autoload keeps a refernce to which puzzle the player selected

var layout: int = -1:
	set(value):
		layout = value
		#print("The value of layout was changed to %s" % layout)
var players: int = -1:
	set(value):
		players = value
		#print("The value of players was changed to %s" % players)
var goals: int = -1:
	set(value):
		goals = value
		#print("The value of goals was changed to %s" % goals)
