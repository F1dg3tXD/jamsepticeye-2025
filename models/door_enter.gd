extends Node3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var area_3d: Area3D = $Area3D
@onready var area_3d_2: Area3D = $entered/Area3D2
#@export var entered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.set("parameters/conditions/isOpen", false)
	animation_tree.set("parameters/conditions/!isOpen", true)
	area_3d.set_deferred("monitoring", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_pawn"):
		animation_tree.set("parameters/conditions/isOpen", true)
		animation_tree.set("parameters/conditions/!isOpen", false)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player_pawn"):
		animation_tree.set("parameters/conditions/isOpen", false)
		animation_tree.set("parameters/conditions/!isOpen", true)
		await get_tree().create_timer(0.01).timeout
		area_3d.set_deferred("monitoring", true)
	else:
		animation_tree.set("parameters/conditions/isOpen", false)
		animation_tree.set("parameters/conditions/!isOpen", true)
		area_3d.set_deferred("monitoring", true)

#func _on_area_3d_2_body_entered(body: Node3D) -> void:
	#if body.is_in_group("player_pawn"):
		#entered = true
