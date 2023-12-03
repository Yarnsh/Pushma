extends CharacterBody3D

@onready var collider = $CollisionShape3D
@onready var follower = $"../UnragdollFollower"
@onready var anim_player = $Guy/AnimationPlayer
@onready var skeleton = $Guy/RootNode/Armature/Skeleton3D
@onready var hip_bone = $"Guy/RootNode/Armature/Skeleton3D/Physical Bone mixamorig_Hips"

var pose_override = 0.0
var ragdolled = false
var unragdoll_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("Armature|WalkForward", 1.0)

func _process(delta):
	pose_override = max(0.0, pose_override - delta * 2.5)
	
	if !ragdolled:
		if pose_override > 0.0:
			var idx = 0
			while idx < skeleton.get_bone_count():
				skeleton.set_bone_global_pose_override(idx, skeleton.get_bone_global_pose_override(idx), pose_override, true)
				idx += 1
		else:
			skeleton.clear_bones_global_pose_override()
	else:
		if Time.get_ticks_msec() >= unragdoll_time:
			unragdoll()

func _physics_process(delta):
	if !ragdolled:
		velocity.y -= 9.8 * delta
		move_and_slide()

func ragdoll(time):
	if !ragdolled:
		skeleton.physical_bones_start_simulation()
	ragdolled = true
	var new_time = Time.get_ticks_msec() + (time * 1000)
	if new_time > unragdoll_time:
		unragdoll_time = new_time
	collider.disabled = true

func unragdoll():
	var pre_skeleton = Transform3D(skeleton.global_transform)
	var pre_turn = global_rotation.y
	if Vector3.UP.dot(hip_bone.global_transform.basis.y) > 0:
		#unragdolling while facing upish
		var forward = Plane(Vector3.UP).project(-hip_bone.global_transform.basis.z)
		look_at(global_position + forward)
	else:
		#unragdolling while facing downish
		var forward = Plane(Vector3.UP).project(hip_bone.global_transform.basis.z)
		look_at(global_position + forward)
	var inverse_turn = pre_turn - global_rotation.y
	
	set_global_position(follower.global_position)
	var inverse_change = skeleton.global_transform.inverse() * pre_skeleton 
	
	var bone_poses = []
	var idx = 0
	while idx < skeleton.get_bone_count():
		bone_poses.append(skeleton.get_bone_global_pose(idx))
		idx += 1
	
	skeleton.physical_bones_stop_simulation()
	ragdolled = false
	
	idx = 0
	while idx < skeleton.get_bone_count():
		var new_pose = inverse_change * bone_poses[idx]
		skeleton.set_bone_global_pose_override(idx, new_pose, 1.0, true)
		idx += 1
	
	pose_override = 1.0
	collider.disabled = false
