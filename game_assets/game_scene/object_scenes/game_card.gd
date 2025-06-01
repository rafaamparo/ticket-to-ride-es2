class_name GameCard extends Node2D

signal hovered
signal hoveredOff

var posicaoInicial
@export var card_index: int = 0;
@export var cor: int = 0
@export var raridade:int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	$CardSprite.vframes = 4  # 4 rows
	$CardSprite.hframes = 2  # 2 columns
	
	update_card_sprite()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Updates the card sprite based on the card index
func update_card_sprite() -> void:
	$CardSprite.frame = card_index
	
# Function to set card index and update sprite
func set_card_index(index: int) -> void:
	card_index = index
	update_card_sprite()


func _on_area_2d_mouse_entered() -> void:
	#print("passouuu")
	emit_signal("hovered", self)
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveredOff", self)
	pass # Replace with function body.
