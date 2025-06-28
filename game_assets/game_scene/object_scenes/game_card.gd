class_name GameCard extends Node2D

signal hovered
signal hoveredOff

var posicaoInicial
var isBeingAdded: bool = false
var previous_rotation
var previous_position 
var y_offset: int = 0
var is_focused: bool = false

@export var card_index: int = 0;
@export var cor: int = 0
@export var raridade:int = 10



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conectarDetectoresDeMovimento()
	$CardSprite.vframes = 4  # 4 rows
	$CardSprite.hframes = 2  # 2 columns
	y_offset = randi_range(0, 25)
	update_card_sprite()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func conectarDetectoresDeMovimento() -> void:
	if (get_parent().has_method("connect_card_signals")):
		get_parent().connect_card_signals(self)
	
func desconectarDetectoresDeMovimento() -> void:
	get_parent().disconnect_card_signals(self)

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
