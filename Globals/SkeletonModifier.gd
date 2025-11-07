@tool
class_name SkeletonIKChain3D
extends SkeletonModifier3D

@export var target: Node3D
@export var chain_bones: Array[String] = []
@export_range(0.0, 1.0) var strength: float = 1.0
@export_range(1, 20) var iterations: int = 8
@export var tolerance: float = 0.01
@export var up_vector: Vector3 = Vector3.UP

func _enter_tree() -> void:
	set_process(true)

func _process_modification() -> void:
	var sk := get_skeleton()
	if sk == null or target == null or chain_bones.size() == 0:
		return

	# Cache bone indices
	var bone_ids: Array[int] = []
	for bname in chain_bones:
		var id := sk.find_bone(bname)
		if id != -1:
			bone_ids.append(id)
	if bone_ids.is_empty():
		return

	# Get current target and tip
	var target_pos := target.global_transform.origin
	var tip_id: int = bone_ids.back()
	var tip_pos := sk.get_bone_global_pose(tip_id).origin

	# --- CCD iterations ---
	for _i in range(iterations):
		# Work backward from tip to root
		for j in range(bone_ids.size() - 2, -1, -1):
			var bone_id := bone_ids[j]
			var bone_tf := sk.get_bone_global_pose(bone_id)

			# Current positions
			tip_pos = sk.get_bone_global_pose(tip_id).origin
			var to_tip := tip_pos - bone_tf.origin
			var to_target := target_pos - bone_tf.origin

			if to_tip.length_squared() < 0.000001 or to_target.length_squared() < 0.000001:
				continue

			# Find rotation between vectors
			to_tip = to_tip.normalized()
			to_target = to_target.normalized()

			var axis := to_tip.cross(to_target).normalized()
			var angle := acos(clamp(to_tip.dot(to_target), -1.0, 1.0))

			if axis.length_squared() < 0.000001:
				continue

			var rotation := Quaternion(axis, angle)
			bone_tf.basis = Basis(rotation) * bone_tf.basis

			# Apply new transform
			sk.set_bone_global_pose_override(bone_id, bone_tf, 1.0, true)

		# Update tip position after this iteration
		tip_pos = sk.get_bone_global_pose(tip_id).origin

		if tip_pos.distance_to(target_pos) < tolerance:
			break

	# --- Apply blending (strength) ---
	if strength < 1.0:
		for bid in bone_ids:
			var original_tf := sk.get_bone_global_pose(bid)
			var modified_tf := sk.get_bone_global_pose_override(bid)
			if modified_tf:
				original_tf.basis = original_tf.basis.slerp(modified_tf.basis, strength)
				original_tf.origin = original_tf.origin.lerp(modified_tf.origin, strength)
				sk.set_bone_global_pose_override(bid, original_tf, 1.0, true)
