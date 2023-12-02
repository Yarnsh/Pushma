extends SubViewport

@export var pixel_multiplier : float

var real_size

# Called when the node enters the scene tree for the first time.
func _ready():
	update_resolution()

func update_resolution():
	real_size = get_parent().get_viewport().get_visible_rect().size
	set_size(real_size / pixel_multiplier)
