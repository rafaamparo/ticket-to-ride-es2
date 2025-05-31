class_name Vagao extends Node2D

@onready var sprite: Sprite2D = $Sprite2D # Assumes a child Sprite2D node named "Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Parent TrilhaVagao will call update_saturation if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_saturation(is_captured: bool) -> void:
	if sprite:
		if not is_captured:
			sprite.modulate.v = 0.5 # 50% saturation
		else:
			sprite.modulate.v = 1.0 # 100% saturation (full color)
