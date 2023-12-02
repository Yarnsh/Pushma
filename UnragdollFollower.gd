extends CharacterBody3D

@onready var shape = $CollisionShape3D
@onready var shape_resource = preload("res://TallCapsule.tres")
@onready var to_follow = $"../GuyBody/Guy/RootNode/Armature/Skeleton3D/Physical Bone mixamorig_Hips"
@onready var exception_body = $"../GuyBody"

func _ready():
	add_collision_exception_with(exception_body)

func _physics_process(delta):
	var query = PhysicsShapeQueryParameters3D.new()
	query.transform = shape.transform.translated(to_follow.global_position)
	query.shape = shape_resource
	query.margin = 0.04
	query.collision_mask = collision_mask
	query.exclude = [exception_body.get_rid()]
	var intersections = get_world_3d().direct_space_state.intersect_shape(query, 1)
	
	if len(intersections) <= 0:
		global_position = to_follow.global_position
	else:
		velocity = (to_follow.global_position - global_position) / delta
		move_and_slide()
