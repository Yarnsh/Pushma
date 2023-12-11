extends Node3D

#TODO: modes like network player or bots here
@export var is_player = false

@onready var guybody = $GuyBody

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_player:
		guybody.set_as_player()
	else:
		guybody.set_as_bot()
