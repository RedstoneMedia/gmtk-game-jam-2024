extends RigidBody3D

@export var axis_scale_by: Vector3 = Vector3.ONE
@export var mass_scale_by: float = 0.01
@export var min_scale: Vector3 = Vector3(0.1, 0.1, 0.1)
@export var max_scale: Vector3 = Vector3(5, 5, 5)

@onready var mesh = $Mesh
@onready var collision_shape = $CollisionShape3D

var our_scale = Vector3.ONE

func change_size(by: float) -> void:
	var change_amount = axis_scale_by * by
	var new_scale = our_scale + change_amount
	# Don't scale if we're too small/large on any axis
	if new_scale.x < min_scale.x or new_scale.x > max_scale.x or new_scale.y < min_scale.y or new_scale.y > max_scale.y or new_scale.z < min_scale.z or new_scale.z > max_scale.z:
		return 
	# Scale the collider and the mesh not the rigid body
	collision_shape.scale += change_amount
	mesh.scale += change_amount
	mass += by * mass_scale_by
	our_scale = new_scale


func _ready() -> void:
	var initial_scale = scale
	collision_shape.scale *= initial_scale
	mesh.scale *= initial_scale
	our_scale = initial_scale
	scale = Vector3.ONE
