extends Node3D

@onready var output = $"../ScreenOutput2"
@onready var guy = $"../SubViewport/CharacterBody3D"

@export var minimum : float
@export var maximum : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist = guy.global_position.distance_to(global_position)
	var alpha = clamp((dist - minimum) / (maximum - minimum), 0.0, 1.0)
	output.get_material().set_shader_parameter("alpha", alpha)
