extends Node3D

@export var forward_target : SubViewport

func _input(event):
	forward_target.push_input(event)
