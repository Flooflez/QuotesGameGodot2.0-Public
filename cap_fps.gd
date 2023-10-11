extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.max_fps = 30
	print("Capping FPS...")
