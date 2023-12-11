extends CharacterBody3D

#help syncronize things
@export var should_ragdoll = false

@onready var collider = $CollisionShape3D
@onready var follower = $"../UnragdollFollower"
@onready var anim_player = $Guy/AnimationPlayer
@onready var skeleton = $Guy/RootNode/Armature/Skeleton3D
@onready var hip_bone = $"Guy/RootNode/Armature/Skeleton3D/Physical Bone mixamorig_Hips"
@onready var model = $Guy

var pose_override = 0.0
var ragdolled = false
@export var unragdoll_time = 0

#Player things
var is_player = false

const stand_cam_height = 1.41
const crouch_cam_height = 0.9

@onready var camera = $Camera3D
@onready var ragdoll_camera = hip_bone.get_node("RagdollCameraPivot/RagdollCamera")
@onready var hands = $Hands
@onready var push_ray = $Camera3D/RayCast3D

var cam_x = 0.0
var cam_y = 0.0
#TODO: put this in some kind of configuration
var look_sensitivity = 0.01

var walk_speed = 3.0

func _ready():
	for child in skeleton.get_children():
		if child is PhysicalBone3D:
			push_ray.add_exception(child)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _process(delta):
	#For some reason adding cameras we dont even use will switch the current camera
	#Setting the correct one every frame just in case
	if is_player:
		if ragdolled:
			ragdoll_camera.set_current(true)
		else:
			camera.set_current(true)
	
	cam_y = clamp(cam_y, -(PI/2.0) + 0.05, (PI/2.0) - 0.05)
	camera.transform.basis = Basis()
	camera.rotate_object_local(Vector3(0, 1, 0), cam_x)
	camera.rotate_object_local(Vector3(1, 0, 0), cam_y)
	
	pose_override = max(0.0, pose_override - delta * 2.5)
	if !ragdolled:
		if is_player:
			model.set_rotation(Vector3.UP * (cam_x + PI))
		
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
	if should_ragdoll and !ragdolled:
		ragdoll(-1.0)
	if !should_ragdoll and ragdolled:
		unragdoll()
	
	if !ragdolled:
		#TODO: move input control out so we can have bots
		#TODO: change collider when crouching
		if is_player:
			if Input.is_action_pressed("crouch"):
				camera.position = Vector3.UP * crouch_cam_height
			else:
				camera.position = Vector3.UP * stand_cam_height
			
			var dir = Vector3.ZERO
			var forward = -camera.global_transform.basis.z
			forward.y = 0.0
			forward = forward.normalized()
			var right = camera.global_transform.basis.x
			if is_on_floor():
				if Input.is_action_pressed("forward"):
					dir += forward
				if Input.is_action_pressed("back"):
					dir -= forward
				if Input.is_action_pressed("right"):
					dir += right
				if Input.is_action_pressed("left"):
					dir -= right
				dir = dir.normalized()
				
				velocity.x = dir.x * walk_speed
				velocity.z = dir.z * walk_speed
				velocity.y += dir.y * walk_speed
		
		velocity.y -= 9.8 * delta
		
		move_and_slide()

func _input(event):
	#TODO: move this out to some more global place
	if is_player:
		if event.is_action_pressed("test"):
			ragdoll(4.0)
		
		if event.is_action_pressed("quit"):
			get_tree().quit()
			
		if event.is_action_pressed("push"):
			hands.push()
			push_ray.force_raycast_update()
			var col = push_ray.get_collider()
			if col != null:
				var col_parent = col.get_parent()
				if col_parent.has_method("get_pushed"):
					col_parent.get_pushed(String(col.name), -camera.global_transform.basis.z * 250.0, push_ray.get_collision_point() - col.global_position)
		
		if event is InputEventMouseMotion:
			cam_x += event.relative.x * -(look_sensitivity)
			cam_y += event.relative.y * -(look_sensitivity)

func ragdoll(time):
	if !ragdolled:
		skeleton.physical_bones_start_simulation()
	ragdolled = true
	should_ragdoll = true
	if time > 0: #Allow ragdolls that dont change the ragdoll timer for online
		var new_time = Time.get_ticks_msec() + (time * 1000)
		if new_time > unragdoll_time:
			unragdoll_time = new_time
	collider.disabled = true
	
	if is_player:
		camera.current = false
		ragdoll_camera.current = true
		model.show()

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
	should_ragdoll = false
	
	idx = 0
	while idx < skeleton.get_bone_count():
		var new_pose = inverse_change * bone_poses[idx]
		skeleton.set_bone_global_pose_override(idx, new_pose, 1.0, true)
		idx += 1
	
	pose_override = 1.0
	collider.disabled = false
	
	if is_player:
		ragdoll_camera.current = false
		camera.current = true
		model.hide()

func set_as_player():
	is_player = true
	camera.set_current(true)
	model.hide()

func set_as_bot():
	is_player = false
	model.show()
