class_name GerenciadorDeFluxo extends Node

const qtd_jogadores_bot: int = 3
var lista_jogadores: Array[Jogador] = []
var jogador_principal: Jogador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Criar o jogador principal
	jogador_principal = Jogador.new()
	jogador_principal.nome = "Jogador Principal"
	jogador_principal.isBot = false
	lista_jogadores.append(jogador_principal)

	# Passar a referência do jogador principal para o gerenciador de UI
	var gerenciador_cartas = get_node_or_null("../GerenciadorCartasJogador")
	if gerenciador_cartas:
		gerenciador_cartas.jogador_principal = jogador_principal

	for i in range(qtd_jogadores_bot):
		var jogador: Jogador = Jogador.new()
		jogador.nome = "Bot " + str(i + 1)
		jogador.trens = 45
		jogador.isBot = true
		jogador.cor = i
		lista_jogadores.append(jogador)
		var jogadorBoxScene = preload("res://game_assets/game_scene/object_scenes/jogador_bot_box.tscn")
		var jogadorBox = jogadorBoxScene.instantiate()
		jogadorBox.jogadorSelecionado = jogador
		$"../GUI/BoxJogadoresContainer".add_child(jogadorBox)
		
	gerenciador_cartas.inicializar_cartas_jogador()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
