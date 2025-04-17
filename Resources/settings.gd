class_name Settings
extends Resource

@export var x: int = 0
@export var vsync: DisplayServer.VSyncMode

enum  Resolution {
	
}

#@export var vsync: bool = true

func hello():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED) 
