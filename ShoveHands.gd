extends Node2D

@onready var sprite = $ShoveHands
var scale_one_resolution = 3500
var push_interp = 1.0

const height_2 = 3500.0
const scale_2 = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("update_resolution")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var interp = abs(push_interp)
	if push_interp < 0.0:
		interp = interp * 20.0
	
	sprite.scale = Vector2.ONE * lerp(1.0, scale_2, interp)
	sprite.position = Vector2(sprite.position.x, lerp(450.0, height_2, interp))
	
	push_interp = min(1.0, push_interp + delta)

func update_resolution():
	var real_size = get_parent().get_viewport().get_visible_rect().size
	scale = Vector2.ONE * (real_size.x / scale_one_resolution)
	set_position(real_size / 2.0)

func push():
	push_interp = -0.05
