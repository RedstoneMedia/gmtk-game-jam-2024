extends Node3D

signal button_pressed
signal button_released

@onready var pad = $Pad
@onready var area = $Area3D

var is_pressed: bool = false
var bodies = 0

const MIN_PAD_HEIGHT = 0.15
const MAX_PAD_HEIGHT = 0.5
const BUTTON_MOVE_SPEED = 3.0

func _physics_process(delta: float) -> void:
	var target_height = MIN_PAD_HEIGHT if is_pressed else MAX_PAD_HEIGHT
	var pad_height = pad.transform.origin.y
	var force = target_height - pad_height
	pad.transform.origin.y = clamp(pad_height + force * delta * BUTTON_MOVE_SPEED, 0.0, MAX_PAD_HEIGHT)


func _on_area_3d_body_entered(body: Node3D) -> void:
	is_pressed = true
	bodies += 1
	if bodies == 1:
		emit_signal("button_pressed")


func _on_area_3d_body_exited(body: Node3D) -> void:
	bodies -= 1
	if bodies == 0:
		is_pressed = false
		emit_signal("button_released")
