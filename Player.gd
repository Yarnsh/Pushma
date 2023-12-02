extends CharacterBody3D

const stand_cam_height = 0.74
const crouch_cam_height = -0.1

@onready var camera = $Camera3D
@onready var hands = $Hands
@onready var push_ray = $Camera3D/RayCast3D

var cam_x = 0.0
var cam_y = 0.0
var look_sensitivity = 0.01

var walk_speed = 3.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	cam_y = clamp(cam_y, -(PI/2.0) + 0.05, (PI/2.0) - 0.05)
	camera.transform.basis = Basis()
	camera.rotate_object_local(Vector3(0, 1, 0), cam_x)
	camera.rotate_object_local(Vector3(1, 0, 0), cam_y)

func _physics_process(delta):
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
		
		velocity.x = dir.x * walk_speed
		velocity.z = dir.z * walk_speed
		velocity.y += dir.y * walk_speed
	
	velocity.y -= 9.8 * delta
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
		
	if event.is_action_pressed("push"):
		hands.push()
		push_ray.force_raycast_update()
		var col = push_ray.get_collider()
		if col != null:
			var col_parent = col.get_parent()
			if col_parent.has_method("get_pushed"):
				col_parent.get_pushed()
				col.apply_impulse(-camera.global_transform.basis.z * 150.0, push_ray.get_collision_point() - col.global_position)
	
	if event is InputEventMouseMotion:
		cam_x += event.relative.x * -(look_sensitivity)
		cam_y += event.relative.y * -(look_sensitivity)
