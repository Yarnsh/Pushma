extends Button

@onready var game_starter = $"../../.."

func _ready():
	pressed.connect(game_starter.join)
