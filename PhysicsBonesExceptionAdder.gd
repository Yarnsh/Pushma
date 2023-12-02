extends Skeleton3D

@onready var guy = $"../../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is PhysicalBone3D:
			for other in get_children():
				if other != child and other is PhysicalBone3D:
					child.add_collision_exception_with(other)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_pushed():
	guy.ragdoll(4.0)
