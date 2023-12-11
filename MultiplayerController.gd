extends Node3D

@onready var world_root = $"../SubViewport"

@onready var start_menu = $"TestMenu"
@onready var guy_prefab = preload("res://BasicGuy.tscn")
@onready var player_spawns_prefab = preload("res://player_spawns.tscn")
@onready var actor_parent = $"../SubViewport/Actors"

@onready var spawner = $"MultiplayerSpawner"
@onready var spawn_node = $"../SubViewport/Actors"

var own_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print(actor_parent.get_children())

func join():
	start_menu.hide()
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("127.0.0.1", 8088)
	if error:
		print(error)
		get_tree().quit()
	multiplayer.multiplayer_peer = peer
	own_id = peer.get_unique_id()
	print("CONNECTED")
	
	var player_spawns = player_spawns_prefab.instantiate()
	player_spawns.set_name(str(own_id) + "_spawns")
	world_root.add_child(player_spawns)
	
	var guy = guy_prefab.instantiate()
	guy.set_name(str(own_id))
	guy.is_player = true
	player_spawns.add_child(guy, true)

func host():
	start_menu.hide()
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(8088, 32)
	if error:
		print(error_string(error))
		get_tree().quit()
	multiplayer.multiplayer_peer = peer
	own_id = peer.get_unique_id()
	print("HOSTING")
	
	var player_spawns = player_spawns_prefab.instantiate()
	player_spawns.set_name(str(own_id) + "_spawns")
	world_root.add_child(player_spawns)
	
	var guy = guy_prefab.instantiate()
	guy.set_name(str(own_id))
	guy.is_player = true
	player_spawns.add_child(guy, true)

func _on_player_connected(id):
	var player_spawns = player_spawns_prefab.instantiate()
	player_spawns.set_name(str(id) + "_spawns")
	world_root.add_child(player_spawns)
