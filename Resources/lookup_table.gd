class_name LookupTable
extends Resource

## How the lookup table works. The key and value are Vector2i. This means they
## each hold 2 64-bit integers. For the key, the x value is the wall data while
## the y value is the current position of the tiles.
## For the value, the x value is the position of the tiles if they all moved
## left with respect to the wall data and other tiles. The y value is if they
## all move right.
@export var Primary: Dictionary[Vector2i, Vector2i]
