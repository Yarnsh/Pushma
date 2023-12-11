extends Camera3D

@export var other_port : SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var other = other_port.get_camera_3d()
	if other != null:
		global_rotation = other.global_rotation
