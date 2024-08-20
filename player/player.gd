extends CharacterBody3D

# Credit: https://github.com/rbarongr/GodotFirstPersonController/blob/main/Player/player.gd

@export var laser: Node3D
@onready var eyes = $Eyes
@onready var camera = $Camera3D
@export var target_node : Node3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 0.65 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var is_firing: bool = false
var shrinking: bool = false

const SIZE_CHANGE_SPEED: float = 0.04

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true

func _physics_process(delta: float) -> void:
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()
	if is_firing:
		update_laser()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == 1 or event.button_index == 2):
		shrinking = event.button_index == 2
		if event.is_pressed() and not is_firing:
			fire_laser()
		else:
			stop_firing()


func update_laser(length: float = 100) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	# Raycast from the camera and pick any colliding object
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * length
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	# Update the laser position and target
	var target = to
	if result:
		target = result.position
	target_node.global_position = target
	laser.global_position = eyes.global_position
	if not "collider" in result:
		return
	var hit_node : Node = result.collider
	if hit_node.is_in_group("sizeable"):
		change_object_size(hit_node)


func change_object_size(object: Node3D) -> void:
	object.change_size(-SIZE_CHANGE_SPEED if shrinking else SIZE_CHANGE_SPEED)


func fire_laser() -> void:
	is_firing = true
	laser.color = Color.BLUE if shrinking else Color.RED
	laser.show()

func stop_firing() -> void:
	is_firing = false
	laser.hide()
