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
			sprite.modulate.v = 1 # 50% saturation
			sprite.modulate.r = 0.8 # 50% saturation
			sprite.modulate.g = 0.8 # 50% saturation
			sprite.modulate.b = 0.8 # 50% saturation
			# reduce opacity to make it look faded
			sprite.modulate.a = 0.9 # 50% opacity
		else:
			sprite.modulate.a = 1
			sprite.modulate.v = 1.2 # 100% saturation (full color)
			# make it brighter by increasing the value (brightness)
			sprite.modulate.r = 1.3
			sprite.modulate.g = 1.3
			sprite.modulate.b = 1.3

func highlight() -> void:
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", initial_scale * 1.2, 0.2) # Increase size by 20%
		# sprite.modulate.r = 1 # 50% saturation
		# sprite.modulate.g = 1 # 50% saturation
		# sprite.modulate.b = 1 # 50% saturation
		sprite.modulate.a = 1
		tween.set_ease(Tween.EASE_IN_OUT)

func unhighlight() -> void:
	if sprite:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", initial_scale, 0.2)
		# sprite.modulate	.r = 0.8 # 50% saturation
		# sprite.modulate.g = 0.8 # 50% saturation
		# sprite.modulate.b = 0.8 # 50% saturation
		sprite.modulate.a = 1 # 50% opacity
		tween.set_ease(Tween.EASE_IN_OUT)
