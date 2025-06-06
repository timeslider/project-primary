extends Node

## This autoload keeps a refernce to which puzzle the player selected

var polyomino: int = -1:
	set(value):
		polyomino = value
		#print("The value of polyomino was changed to %s" % polyomino)
var players: int = -1:
	set(value):
		players = value
		#print("The value of players was changed to %s" % players)
var goals: int = -1:
	set(value):
		goals = value
		#print("The value of goals was changed to %s" % goals)
