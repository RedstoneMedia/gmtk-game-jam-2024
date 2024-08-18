extends Node

@onready var camera : PhantomCamera3D = $"../PhantomCamera3D"

func _ready() -> void:
	setup_level()


func setup_level() -> void:
	var level = get_child(0)
	if not level:
		printerr("Level not found")
		return
	var camera_path = level.get_node("CameraPath")
	if not camera_path is Path3D:
		printerr("CameraPath not found")
		return
	camera.follow_path = camera_path
