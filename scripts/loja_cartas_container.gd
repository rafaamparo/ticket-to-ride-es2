class_name LojaCartasContainer extends VBoxContainer

var isHoveringCard = false;
var gerenciadorDeComprarCartas: GerenciadorComprarCartas = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerenciadorDeComprarCartas = get_node("../GerenciadorComprarCartas") as GerenciadorComprarCartas

func connect_card_signals(card):
	card.connect("hovered", hovered_on_card)
	card.connect("hoveredOff", hovered_off_card)
	
func disconnect_card_signals(card):
	card.disconnect("hovered", hovered_on_card)
	card.disconnect("hoveredOff", hovered_off_card)
	print("descontando da loja")
	
func hovered_on_card(carta: GameCard):
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		highlight_card(carta, true)
		
func hovered_off_card(carta: GameCard):
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		highlight_card(carta,false)

func highlight_card(card, hovered):
		if hovered and gerenciadorDeComprarCartas.verificarSePodeComprarCarta(card):
			var tween1 = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
			tween1.tween_property(card, "scale", Vector2(0.6, 0.6), 0.05)
			await tween1.finished
			card.scale =  Vector2(0.6, 0.6)
			card.z_index = 100
		else:
			var tween2 = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
			tween2.tween_property(card, "scale", Vector2(0.5, 0.5), 0.05)
			card.z_index = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
