extends Node3D

@export var other : Node3D

func _process(delta):
	global_rotation = other.global_rotation
