extends Node

@onready var player = $"../Player"
@onready var win_text = $"../Win Text"
@export var levels: Array[PackedScene]


var current_level: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		var level = get_child(0)
		level.queue_free()
		setup_level(levels[current_level])

func _ready() -> void:
	setup_level(levels[current_level])


func setup_level(level_scene: PackedScene) -> void:
	var level = level_scene.instantiate()
	add_child(level)
	var player_spawn = level.get_node_or_null("Player Spawn")
	if not player_spawn:
		printerr("Player Spawn not found")
		return
	player.global_position = player_spawn.global_position
	player.global_rotation = player_spawn.global_rotation
	var exit = level.get_node_or_null("Exit")
	if not exit:
		printerr("Exit not found")
		return
	exit.connect("exit_entered", next_level)


func next_level() -> void:
	if current_level >= levels.size() - 1:
		print("End of game")
		win_text.show()
		return
	current_level += 1
	# Remove current level
	var level = get_child(0)
	level.queue_free()
	print("Next level")
	setup_level(levels[current_level])
