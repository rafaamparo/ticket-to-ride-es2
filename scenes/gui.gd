extends CanvasLayer
var card_manager: GerenciadorCartasJogador = null
var store_manager: GerenciadorComprarCartas = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_manager = $"../GerenciadorCartasJogador"
	store_manager = $GerenciadorComprarCartas
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if store_manager.cartas_da_loja.size() >= store_manager.max_num_cartas_loja:
		$BotaoDePegarCartas.disabled = true
	else:
		$BotaoDePegarCartas.disabled = false



func _on_button_pressed() -> void:
	#card_manager.gerarCartaAleatoria()
	
	var trilhoSelecionado = $"../GerenciadorDeTrilhas/TrilhaVagao48"
	var camera = $"../Camera2D"
	var jogadorSelecionado = $"../GerenciadorDeFluxoJogo".lista_jogadores[2]
	var gerenciadorDeFluxo = $"../GerenciadorDeFluxoJogo"
	
	jogadorSelecionado.capturarRotaBot(trilhoSelecionado, camera, gerenciadorDeFluxo)
	store_manager.adicionarCartaAleatoriaNaLoja()
	pass # Replace with function body.
