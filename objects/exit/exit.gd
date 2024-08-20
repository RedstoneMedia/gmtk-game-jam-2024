extends Node3D

@onready var close_part: Node3D = $"Door-wide-closed"
@onready var close_shape: CollisionShape3D = $"Door-wide-closed/StaticBody3D/CollisionShape3D"
@export var is_open: bool = false

signal exit_entered

func _on_area_body_entered(body: Node3D) -> void:
	emit_signal("exit_entered")

func _physics_process(delta: float) -> void:
	var target_height = 0.5 if is_open else 0.0
	var door_height = close_part.transform.origin.y
	# Lerp door height
	close_part.transform.origin.y = lerp(door_height, target_height, delta * 10.0)
	if is_open and abs(door_height - target_height) < 0.0001:
		close_part.hide()
		close_shape.disabled = true
	else:
		close_part.show()
		close_shape.disabled = false


func _on_open():
	is_open = true

func _on_close():
	is_open = false
