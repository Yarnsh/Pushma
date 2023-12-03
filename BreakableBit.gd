extends RigidBody3D

@onready var parent_obj = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", on_body_enter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_body_enter(body):
	parent_obj.unfreeze()
