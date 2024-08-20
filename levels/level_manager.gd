extends Node

@onready var player = $"../Player"

func _ready() -> void:
	setup_level()


func setup_level() -> void:
	var level = get_child(0)
	if not level:
		printerr("Level not found")
		return
	var player_spawn = level.get_node_or_null("Player Spawn")
	if not player_spawn:
		printerr("Player Spawn not found")
		return
	player.global_position = player_spawn.global_position
