class_name GerenciadorDeFluxo extends Node

const qtd_jogadores_bot: int = 3
var textDialog: TextDialog = null
var lista_jogadores: Array[Jogador] = []
var jogador_principal: Jogador
var pausar_jogador_principal: bool = false
var jogador_do_turno: int = 1
var contador_de_rodadas: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textDialog = $"../GUI/TextDialog"
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
		jogador.gerarCartasBot()
		var jogadorBoxScene = preload("res://game_assets/game_scene/object_scenes/jogador_bot_box.tscn")
		var jogadorBox = jogadorBoxScene.instantiate()
		jogadorBox.jogadorSelecionado = jogador
		$"../GUI/BoxJogadoresContainer".add_child(jogadorBox)
		
	gerenciador_cartas.inicializar_cartas_jogador()

	gerenciadorDeTurno()

func gerenciadorDeTurno() -> void:
	pausar_jogador_principal = true
	contador_de_rodadas += 1;
	await get_tree().create_timer(1.0).timeout
	await textDialog.hide_dialog()

	if contador_de_rodadas == 0:
		await textDialog.show_dialog_with_text("Sorteando Jogador...");
		await get_tree().create_timer(3.0).timeout
		jogador_do_turno = randi() % lista_jogadores.size()
	else:
		await textDialog.show_dialog_with_text("Intervalo...");
		await get_tree().create_timer(5.0).timeout
	
	await textDialog.hide_dialog()

	var jogador_atual_do_turno: Jogador = lista_jogadores[jogador_do_turno]
	if jogador_atual_do_turno.isBot:
		rodada_bot()
	else:
		rodadaJogadorPrincipal()
	
	
	
func rodada_bot() -> void:
	var gerenciadorDeTrilhas = $"../GerenciadorDeTrilhas"

	var jogador_atual: Jogador = lista_jogadores[jogador_do_turno]
	if jogador_atual.isBot:
		pausar_jogador_principal = true
		print("É a vez do bot: ", jogador_atual.nome)
		await get_tree().create_timer(1.0).timeout
		await textDialog.show_dialog_with_text("É a vez do jogador %s" % jogador_atual.nome)
		await get_tree().create_timer(2.0).timeout  # Espera 1 segundo antes de continuar
		await textDialog.hide_dialog()
		await get_tree().create_timer(1.0).timeout
		print("Bot está jogando...")
		textDialog.show_dialog_with_text("%s está jogando..." % jogador_atual.nome)

		var resultado = await jogador_atual.capturarRotaBot(gerenciadorDeTrilhas)
		print("Resultado da captura: ", resultado)
		if resultado:
			print("Bot capturou uma rota!")
			await textDialog.show_dialog_with_text("%s capturou uma rota!" % jogador_atual.nome)
		else:
			print("%s não conseguiu capturar uma rota." % jogador_atual.nome)

		proximoTurno()
	return;


func proximoTurno() -> void:
	jogador_do_turno += 1
	if jogador_do_turno >= lista_jogadores.size():
		jogador_do_turno = 0
	gerenciadorDeTurno()


func rodadaJogadorPrincipal() -> void:
	pausar_jogador_principal = false
	print("É a vez do jogador principal: ", jogador_principal.nome)
	await get_tree().create_timer(1.0).timeout
	await textDialog.show_dialog_with_text("É a vez do jogador %s" % jogador_principal.nome)
	await get_tree().create_timer(2.0).timeout  # Espera 1 segundo antes de continuar
	await textDialog.hide_dialog()
	await get_tree().create_timer(1.0).timeout
	await textDialog.show_dialog_with_text("É a sua vez de jogar! Capture uma rota ou compre cartas.")
	await get_tree().create_timer(15.0).timeout

	# Aqui você pode adicionar a lógica para o jogador principal jogar
	# Por exemplo, permitir que ele escolha uma carta ou uma ação

	proximoTurno()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
