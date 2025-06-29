extends CanvasLayer
var card_manager: GerenciadorCartasJogador = null
var store_manager: GerenciadorComprarCartas = null
var btn_comprar_cartas: BotaoComprarCartasBaralho = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_manager = $"../GerenciadorCartasJogador"
	store_manager = $GerenciadorComprarCartas
	btn_comprar_cartas = $BotaoComprarCarta
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_botao_comprar_carta_pressed() -> void:

	if btn_comprar_cartas.desativado:
		print("Botão de compra de cartas desativado, não pode comprar")
		return

	var cartaGerada = card_manager.gerarCartaAleatoria()
	btn_comprar_cartas.comprarCartaBaralho(card_manager.jogador_principal, cartaGerada)
		
	

	pass # Replace with function body.
