extends Node

func _ready() -> void:
	setup_level()


func setup_level() -> void:
	var level = get_child(0)
	if not level:
		printerr("Level not found")
		return
