extends CharacterBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var animation_tree: AnimationTree = $player/AnimationTree
@onready var head: Node3D = $Head
@export var ice_rect_scene: PackedScene
@export var ice_cube_scene: PackedScene
@onready var pickup: RayCast3D = $Head/RayCast3D

var held_object: RigidBody3D = null

@export var hold_distance: float = 2.0
@export var hold_strength: float = 10.0


var current_rwc: float = 0.0
var current_idw: float = 1.0

# --- Movement constants ---
const SPEED := 5.0
const RUN_SPEED := 8.0
const JUMP_VELOCITY := 4.5

# --- Capsule heights ---
const STAND_HEIGHT := 2.0
const CROUCH_HEIGHT := 1.0
const CROUCH_SPEED := 3.0

# --- Mouse look ---
@export var mouse_sensitivity: float = 0.0025
@export var controller_sensitivity: float = 5.0 # tweak for stick speed
var yaw: float = 0.0
var pitch: float = 0.0

# --- State ---
var is_crouching: bool = false
var target_height: float = STAND_HEIGHT

func _ready() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw += event.relative.x * mouse_sensitivity
		pitch += event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.5, 1.5) # clamp vertical look

		rotation.y = -yaw
		head.rotation.x = pitch
	
	if Input.is_action_just_pressed("ice"):
		respawn()
		
	if Input.is_action_just_pressed("use"):
		if held_object:
			# Release object
			held_object = null
		else:
			# Try to pick up
			if pickup.is_colliding():
				var collider = pickup.get_collider()
				if collider is RigidBody3D:
					held_object = collider

func _process(delta: float) -> void:
	# --- CONTROLLER LOOK ---
	var look_input := Vector2.ZERO
	look_input.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	look_input.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	if look_input.length() > 0.01:
		yaw -= look_input.x * controller_sensitivity * delta
		pitch += look_input.y * controller_sensitivity * delta
		pitch = clamp(pitch, -1.2, 1.2)

		rotation.y = yaw
		head.rotation.x = pitch
	
	# If holding something, keep moving it to the hold position
	if held_object:
		var target_pos = pickup.global_transform.origin + pickup.global_transform.basis.z * -hold_distance
		var dir = target_pos - held_object.global_transform.origin
		held_object.linear_velocity = dir * hold_strength

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# --- Crouch (hold style) ---
	if Input.is_action_pressed("crouch"):
		if not is_crouching:
			start_crouch()
	else:
		if is_crouching:
			stop_crouch()

	# --- Smooth capsule resize ---
	var capsule := collision_shape_3d.shape as CapsuleShape3D
	capsule.height = lerp(capsule.height, target_height, delta * CROUCH_SPEED)

	# Adjust head position
	var head_target_y := target_height * 0.5 + capsule.radius
	head.position.y = lerp(head.position.y, head_target_y, delta * CROUCH_SPEED)

	# --- Smooth movement input with stick magnitude ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_strength := input_dir.length()
	var target_velocity := Vector3.ZERO

	if input_strength > 0.01:
		var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
		var current_speed := SPEED
		if not is_crouching and Input.is_action_pressed("sprint"):
			current_speed = RUN_SPEED
		target_velocity = direction * current_speed * input_strength

	# Smoothly lerp velocity toward target
	var smooth_speed := 10.0 # tweak for responsiveness
	velocity.x = lerp(velocity.x, target_velocity.x, delta * smooth_speed)
	velocity.z = lerp(velocity.z, target_velocity.z, delta * smooth_speed)

	move_and_slide()

	# --- Animation handling ---
	update_animation(delta, input_dir)

func start_crouch() -> void:
	is_crouching = true
	target_height = CROUCH_HEIGHT

func stop_crouch() -> void:
	is_crouching = false
	target_height = STAND_HEIGHT

func update_animation(delta: float, input_dir: Vector2) -> void:
	# Feed input_dir to blend spaces
	animation_tree.set("parameters/Crouch/blend_position", input_dir)
	animation_tree.set("parameters/Walk/blend_position", input_dir)
	animation_tree.set("parameters/Run/blend_position", input_dir)

	# --- Smooth blend between RWC states ---
	var speed2d := Vector2(velocity.x, velocity.z).length()
	var target_rwc: float = 0.0
	var target_idw: float = 1.0

	if is_crouching:
		target_rwc = -1.0
		target_idw = 1.0
	elif speed2d < SPEED * 0.5:
		target_rwc = 0.0
		target_idw = 1.0
	else:
		target_rwc = 1.0
		target_idw = 0.0

	# Smoothly lerp stored values
	var blend_speed := 5.0
	current_rwc = lerp(current_rwc, target_rwc, delta * blend_speed)
	current_idw = lerp(current_idw, target_idw, delta * blend_speed)

	# Apply to AnimationTree
	animation_tree.set("parameters/RWC/blend_amount", current_rwc)
	animation_tree.set("parameters/Idw/blend_amount", current_idw)

func respawn() -> void:
	var spawn: Node3D = null

	if Game.last_checkpoint:
		spawn = Game.last_checkpoint
	else:
		spawn = get_node_or_null(Game.default_spawn)

	if not spawn:
		push_error("No valid spawn point found!")
		return

	# Get player transform BEFORE teleport
	var player_transform := global_transform

	# --- Spawn ice block depending on crouch state ---
	var ice_instance: Node3D
	if is_crouching:
		ice_instance = ice_cube_scene.instantiate()
	else:
		ice_instance = ice_rect_scene.instantiate()

	# Copy the full transform (position, rotation, scale)
	ice_instance.global_transform = player_transform
	get_tree().current_scene.add_child(ice_instance)

	# Teleport player to spawn position (translation only)
	var new_transform := player_transform
	new_transform.origin = spawn.global_transform.origin
	global_transform = new_transform

	velocity = Vector3.ZERO
	print("Respawned at:", spawn.global_transform.origin)
