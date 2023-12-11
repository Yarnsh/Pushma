extends Node3D

@onready var spawner = $"MultiplayerSpawner"

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner.spawn_path = ".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
