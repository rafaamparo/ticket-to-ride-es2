class_name Vagao extends Node2D

@onready var sprite: Sprite2D = $Sprite2D # Assumes a child Sprite2D node named "Sprite2D"
var initial_scale: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial scale of the sprite
	initial_scale = sprite.scale if sprite else Vector2(1, 1)
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

func highlight() -> void:
	# Highlight is for when the vagao is selected or hovered. I would like to to change scale and make it glow.
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", initial_scale * 1.2, 0.2) # Increase size by 20%
		tween.set_ease(Tween.EASE_IN_OUT)
		# sprite.modulate = Color(1.0, 1.0, 0.25, 1.0) # Tint yellow, allowing some blue from the texture to show

func unhighlight() -> void:
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", initial_scale, 0.2) # Reset scale to initial size
		tween.set_ease(Tween.EASE_IN_OUT)
		# sprite.modulate = Color(1, 1, 1, 1) # Reset color to white
