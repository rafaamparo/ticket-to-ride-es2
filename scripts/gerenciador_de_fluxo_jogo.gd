class_name GerenciadorDeFluxo extends Node

const qtd_jogadores_bot: int = 3
var gerenciadorDeComprarCartas: GerenciadorComprarCartas = null
var textDialog: TextDialog = null
var lista_jogadores: Array[Jogador] = []
var jogador_principal: Jogador
var pausar_jogador_principal: bool = false
var jogador_do_turno: int = 1
var contador_de_rodadas: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textDialog = $"../GUI/TextDialog"
	gerenciadorDeComprarCartas = $"../GUI/GerenciadorComprarCartas"
	# Criar o jogador principal
	jogador_principal = Jogador.new()
	jogador_principal.nome = "Rafael A."
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
		await get_tree().create_timer(3.5).timeout  # Espera 3.5 segundos antes de continuar
		await textDialog.hide_dialog()
		await get_tree().create_timer(1.0).timeout
		print("Bot está jogando...")
		textDialog.show_dialog_with_text("%s está jogando..." % jogador_atual.nome)

		var chance_de_comprar_carta = randi_range(1,10) <= 2

	
		if chance_de_comprar_carta:
			await bot_compra_carta(jogador_atual)
		else:
			var resultado = await bot_decide_capturar_rota(jogador_atual, gerenciadorDeTrilhas)
			if not resultado:
				await get_tree().create_timer(1.0).timeout
				await bot_compra_carta(jogador_atual)

		proximoTurno()
	return;

func bot_decide_capturar_rota(jogador_atual: Jogador, gerenciadorDeTrilhas: GerenciadorDeTrilhas) -> bool:
	var resultado = await jogador_atual.capturarRotaBot(gerenciadorDeTrilhas)
	print("Resultado da captura: ", resultado)
	if resultado:
		print("Bot capturou uma rota!")
		await textDialog.show_dialog_with_text("%s capturou uma rota!" % jogador_atual.nome)
		return true
	else:
		print("%s não conseguiu capturar uma rota." % jogador_atual.nome)
		await textDialog.show_dialog_with_text("%s pensou em capturar rota mas não conseguiu." % jogador_atual.nome)
		return false

func bot_compra_carta(jogador_atual: Jogador) -> void:
	await textDialog.show_dialog_with_text("%s vai comprar cartas." % jogador_atual.nome)
	await get_tree().create_timer(2.0).timeout

	var cartas_compradas_neste_turno = 0
	while cartas_compradas_neste_turno < gerenciadorDeComprarCartas.max_cartas_para_comprar:
		var cartas_disponiveis = gerenciadorDeComprarCartas.cartas_da_loja
		if cartas_disponiveis.is_empty():
			break # Sai do loop se não há mais cartas na loja

		var carta_escolhida = null
		# Prioriza a carta coringa (card_index == 7)
		var cartas_coringa = cartas_disponiveis.filter(func(c): return c.card_index == 7)
		if not cartas_coringa.is_empty():
			carta_escolhida = cartas_coringa[0]
		else:
			carta_escolhida = cartas_disponiveis.pick_random()

		if carta_escolhida and gerenciadorDeComprarCartas.verificarSePodeComprarCarta(carta_escolhida):
			await gerenciadorDeComprarCartas.comprarCartaDaLoja(jogador_atual, carta_escolhida)
			await textDialog.show_dialog_with_text("%s comprou uma carta!" % jogador_atual.nome)
			await get_tree().create_timer(1.5).timeout
			cartas_compradas_neste_turno += 1
			if carta_escolhida.card_index == 7: # Se comprou um coringa, não pode comprar mais
				break
		else:
			# Se não pode comprar a carta (ex: já comprou o máximo, ou é coringa e já comprou uma),
			# o bot não vai tentar comprar outra carta nesta rodada para simplificar.
			break

func proximoTurno() -> void:
	jogador_do_turno += 1
	gerenciadorDeComprarCartas.atualizarTurnoLoja()
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
