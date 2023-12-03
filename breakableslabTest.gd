extends Node3D

@onready var broken_bits = $Broken
var frozen = true

# Called when the node enters the scene tree for the first time.
func _ready():
	for bit in broken_bits.get_children():
		for other_bit in broken_bits.get_children():
			if bit != other_bit:
				bit.add_collision_exception_with(other_bit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("test"):
		for bit in broken_bits.get_children():
			bit.set_freeze_enabled(false)

func unfreeze():
	if frozen:
		frozen = false
		for bit in broken_bits.get_children():
			for other in bit.get_collision_exceptions():
				bit.remove_collision_exception_with(other)
		for bit in broken_bits.get_children():
			bit.set_freeze_enabled(false)
