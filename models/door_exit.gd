extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@export var buttons: Array[NodePath] = []
@onready var area_3d: Area3D = $Area3D
#@export var next_scene: String

var button_nodes: Array[ButtonLarge] = []

func _ready() -> void:
	#animation_tree.set("parameters/blend_position")
	animation_tree.set("parameters/conditions/isOpen", false)
	animation_tree.set("parameters/conditions/!isOpen", true)

	# Resolve button nodes and connect signals
	for path in buttons:
		var node = get_node_or_null(path)
		if node and node is ButtonLarge:
			button_nodes.append(node)
			if not node.pressed_changed.is_connected(Callable(self, "_on_button_pressed_changed")):
				node.pressed_changed.connect(Callable(self, "_on_button_pressed_changed"))
		else:
			push_warning("DoorExit: invalid button node at path: " + str(path))

	_check_buttons()

	if not area_3d.body_entered.is_connected(Callable(self, "_on_area_3d_body_entered")):
		area_3d.body_entered.connect(Callable(self, "_on_area_3d_body_entered"))

func _on_button_pressed_changed(_pressed: bool) -> void:
	_check_buttons()

func _check_buttons() -> void:
	var all_pressed := true

	if button_nodes.size() == 0:
		all_pressed = false
	else:
		for button in button_nodes:
			if not button.is_pressed:
				all_pressed = false
				break

	animation_tree.set("parameters/conditions/isOpen", all_pressed)
	animation_tree.set("parameters/conditions/!isOpen", !all_pressed)
	# print("Door open =", all_pressed)

#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("Entered door area:", body)
	#print("Door open =", animation_tree.get("parameters/conditions/isOpen"))
	#if body.is_in_group("player_pawn"):
		#print("Loading next level...")
		#load_next_level()
#
#func load_next_level() -> void:
	#if next_scene == "":
		#push_warning("DoorExit: no next scene path assigned.")
		#return
#
	#if Engine.has_singleton("SceneLoader"):
		#var scene_loader = Engine.get_singleton("SceneLoader")
		#scene_loader.load_scene(next_scene)
	#else:
		#push_warning("DoorExit: SceneLoader singleton not found. Falling back to default change_scene.")
		#get_tree().change_scene_to_file(next_scene)
