extends Node

const qtd_jogadores_bot: int = 3
var lista_jogadores: Array[Jogador] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
