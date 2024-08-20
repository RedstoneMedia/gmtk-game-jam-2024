extends Node3D


@onready var target = $"../Target"
@export var color: Color = Color.RED

func _process(delta: float) -> void:
	var length = (target.global_position - global_position).length()
	scale.z = length
	look_at(target.global_position, Vector3.UP)
	color.a = 0.6
	$Laser.material.albedo_color = color
	
