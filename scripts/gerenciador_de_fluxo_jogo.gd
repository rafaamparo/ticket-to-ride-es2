class_name GerenciadorDeFluxo extends Node

signal acao_jogador_terminada
const qtd_jogadores_bot: int = 3
var gerenciadorDeComprarCartas: GerenciadorComprarCartas = null
var gerenciadorDeCartasDestino: GerenciadorCartasDestino = null
var textDialog: TextDialog = null
var lista_jogadores: Array[Jogador] = []
var jogador_principal: Jogador
var pausar_jogador_principal: bool = false
var pausar_cartas_mao_jogador_princial: bool = false
var jogador_do_turno: int = 1
var contador_de_rodadas: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textDialog = $"../GUI/TextDialog"
	gerenciadorDeComprarCartas = $"../GUI/GerenciadorComprarCartas"
	gerenciadorDeCartasDestino = $"../GUI/GerenciadorCartasDestino";
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
		jogador.trens = 10
		jogador.isBot = true
		jogador.cor = i
		var jogadorBoxScene = preload("res://game_assets/game_scene/object_scenes/jogador_bot_box.tscn")
		var jogadorBox = jogadorBoxScene.instantiate()
		jogadorBox.jogadorSelecionado = jogador
		jogador.player_info_box = jogadorBox;
		lista_jogadores.append(jogador)
		jogador.gerarCartasBot()
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

	
	if verificarSeAlgumJogadorVenceu():
		await fluxoDeFimDeJogo()
		return

	var jogador_atual_do_turno: Jogador = lista_jogadores[jogador_do_turno]
	if jogador_atual_do_turno.isBot:

		rodada_bot()
	else:
		rodadaJogadorPrincipal()
	
	
func verificarSeAlgumJogadorVenceu() -> bool:
	for jogador in lista_jogadores:
		if jogador.trens <= 2: 
			return true
	return false
	
func verificarSeAlgumJogadorCompletouAlgumaRota() -> void:
	for jogador in lista_jogadores:
		var lista_de_cartas_destino = jogador.cartas_destino.duplicate()
		var lista_destino_nao_concluida = lista_de_cartas_destino.filter(
			func(carta: CartaDestino) -> bool: return not carta.concluida
		)

		for carta in lista_destino_nao_concluida:
			if gerenciadorDeCartasDestino.verificarSeJogadorFezCaminho (jogador, carta.pontoInicio, carta.pontoFinal):
				carta.concluida = true
				jogador.pontos += carta.pontuacao
				print("Jogador %s completou a rota de %s a %s e ganhou %d pontos!" % 
					[jogador.nome, carta.pontoInicio.nomeDaParada, carta.pontoFinal.nomeDaParada, carta.pontuacao])
				await textDialog.show_dialog_with_text("%s completou a rota de %s a %s e ganhou %d pontos!" % 
					[jogador.nome, carta.pontoInicio.nomeDaParada, carta.pontoFinal.nomeDaParada, carta.pontuacao])
				await get_tree().create_timer(3.5).timeout
				await textDialog.hide_dialog()
		#verificarSeJogadorFezCaminho

func fluxoDeFimDeJogo() -> void:
	await get_tree().create_timer(1.0).timeout
	await textDialog.show_dialog_with_text("Fim de jogo!")
	await get_tree().create_timer(2.0).timeout
	await textDialog.hide_dialog()
	await textDialog.show_dialog_with_text("Aguarde enquanto calculamos os pontos...")
	await get_tree().create_timer(6.0).timeout
	await textDialog.hide_dialog()
	await verificarSeAlgumJogadorCompletouAlgumaRota()
	

	var ranking: Array[Jogador] = lista_jogadores.duplicate()
	ranking.sort_custom(func(a, b): return a.pontos > b.pontos)
	$"../GUI/Winner-dialog".player_ranking = ranking
	$"../GUI/Winner-dialog".show_dialog_box()

	await $"../GUI/Winner-dialog".wait_for_response()

	# go to the main menu
	var main_menu_scene = preload("res://scenes/main_menu.tscn")
	get_tree().change_scene(main_menu_scene)
	


func rodada_bot() -> void:
	var gerenciadorDeTrilhas = $"../GerenciadorDeTrilhas"

	var jogador_atual: Jogador = lista_jogadores[jogador_do_turno]
	if jogador_atual.isBot:
		pausar_jogador_principal = true
		print("É a vez do bot: ", jogador_atual.nome)
		await get_tree().create_timer(1.0).timeout
		await textDialog.show_dialog_with_text("É a vez do jogador %s" % jogador_atual.nome)
		await get_tree().create_timer(3.5).timeout
		await textDialog.hide_dialog()
		await get_tree().create_timer(1.0).timeout
		textDialog.show_dialog_with_text("%s está jogando..." % jogador_atual.nome)

		# Estratégia do Bot:
		# 1. Tenta capturar uma rota, que é a ação principal para vencer.
		var resultado_captura = await bot_decide_capturar_rota(jogador_atual, gerenciadorDeTrilhas)
		await get_tree().create_timer(2.45).timeout

		var chance_de_comprar_destino = randi() % 100 <= 20 # 20% de chance de comprar carta de destino

		# 2. Se não conseguiu capturar, vai comprar cartas para melhorar a mão.
		if not resultado_captura:
			if chance_de_comprar_destino:
				await gerenciadorDeCartasDestino.pegarCartaDestinoBaralho(jogador_atual)
				await textDialog.show_dialog_with_text("%s comprou uma carta de destino." % jogador_atual.nome)
				await get_tree().create_timer(2.0).timeout
			else:
				print("%s não comprou carta de destino." % jogador_atual.nome)
				await bot_decide_compra(jogador_atual)

		proximoTurno()
	return

func bot_decide_capturar_rota(jogador_atual: Jogador, gerenciadorDeTrilhas: GerenciadorDeTrilhas) -> bool:
	var resultado = await jogador_atual.capturarRotaBot(gerenciadorDeTrilhas)
	if resultado:
		print("Bot capturou uma rota!")
		await textDialog.show_dialog_with_text("%s capturou uma rota!" % jogador_atual.nome)
		return true
	else:
		print("%s não conseguiu capturar uma rota." % jogador_atual.nome)
		await textDialog.show_dialog_with_text("%s pensou em capturar rota mas não conseguiu." % jogador_atual.nome)
		return false

func bot_decide_compra(jogador_atual: Jogador) -> void:
	await textDialog.show_dialog_with_text("%s vai comprar cartas." % jogador_atual.nome)
	await get_tree().create_timer(2.0).timeout

	var cartas_compradas = 0
	while cartas_compradas < gerenciadorDeComprarCartas.max_cartas_para_comprar:
		var comprou_carta = await bot_compra_uma_carta(jogador_atual)
		if not comprou_carta:
			break # Não foi possível comprar mais cartas

		cartas_compradas += 1
		
		# Se comprou um coringa da loja, o turno de compras acaba
		var comprou_coringa_loja = false
		for c in gerenciadorDeComprarCartas.cartas_compradas_turno_loja:
			if c.card_index == 7:
				comprou_coringa_loja = true
				break
		if comprou_coringa_loja:
			break
		
		# Verificação de segurança para o limite de cartas
		if (gerenciadorDeComprarCartas.cartas_compradas_turno_loja.size() + gerenciadorDeComprarCartas.cartas_compradas_turno_baralho.size()) >= gerenciadorDeComprarCartas.max_cartas_para_comprar:
			break

func bot_compra_uma_carta(jogador_atual: Jogador) -> bool:
	var cartas_loja = gerenciadorDeComprarCartas.cartas_da_loja

	# 1. Prioridade máxima: Coringa visível na loja
	var coringas_na_loja = cartas_loja.filter(func(c): return c.card_index == 7)
	if not coringas_na_loja.is_empty():
		var coringa = coringas_na_loja[0]
		if gerenciadorDeComprarCartas.verificarSePodeComprarCarta(coringa):
			await gerenciadorDeComprarCartas.comprarCartaDaLoja(jogador_atual, coringa)
			await textDialog.show_dialog_with_text("%s pegou um coringa da loja!" % jogador_atual.nome)
			await get_tree().create_timer(1.5).timeout
			return true

	# 2. Prioridade média: Carta "útil" da loja (cor que o bot já coleciona)
	var carta_util = encontrar_carta_util_na_loja(jogador_atual, cartas_loja)
	if carta_util != null and gerenciadorDeComprarCartas.verificarSePodeComprarCarta(carta_util):
			await gerenciadorDeComprarCartas.comprarCartaDaLoja(jogador_atual, carta_util)
			await textDialog.show_dialog_with_text("%s pegou uma carta útil da loja." % jogador_atual.nome)
			await get_tree().create_timer(1.5).timeout
			return true
	
	# 3. Prioridade baixa: Comprar do baralho (se possível)
	if gerenciadorDeComprarCartas.verificarSePodePegarDoBaralho():
		gerenciadorDeComprarCartas.comprarCartaDoBaralho(jogador_atual)
		await textDialog.show_dialog_with_text("%s comprou do baralho." % jogador_atual.nome)
		await get_tree().create_timer(1.5).timeout
		return true

	# 4. Último recurso: Comprar qualquer carta aleatória da loja (se não puder comprar do baralho)
	if not cartas_loja.is_empty():
		var carta_aleatoria = cartas_loja.pick_random()
		if gerenciadorDeComprarCartas.verificarSePodeComprarCarta(carta_aleatoria):
			await gerenciadorDeComprarCartas.comprarCartaDaLoja(jogador_atual, carta_aleatoria)
			await textDialog.show_dialog_with_text("%s pegou uma carta aleatória da loja." % jogador_atual.nome)
			await get_tree().create_timer(1.5).timeout
			return true

	return false # Não foi possível comprar nenhuma carta

# Essa função procura uma carta na loja que seja "útil" para o bot, ou seja, uma carta de uma cor que o bot já possui.
func encontrar_carta_util_na_loja(jogador: Jogador, cartas_loja: Array[GameCard]) -> GameCard:
	if cartas_loja.is_empty():
		return null

	var contagem_cores = {}
	for carta in jogador.cartas:
		if carta.card_index != 7: # Ignora coringas
			contagem_cores[carta.card_index] = contagem_cores.get(carta.card_index, 0) + 1
	
	if contagem_cores.is_empty():
		return null # Não tem nenhuma cor para basear a decisão

	# Procura na loja por uma carta de uma cor que o bot já tenha
	for carta_loja in cartas_loja:
		if contagem_cores.has(carta_loja.card_index):
			return carta_loja
	
	return null

func proximoTurno() -> void:
	jogador_do_turno += 1
	gerenciadorDeComprarCartas.atualizarTurnoLoja()
	gerenciadorDeCartasDestino.atualizarTurnoDestino()
	if jogador_do_turno >= lista_jogadores.size():
		jogador_do_turno = 0
	gerenciadorDeTurno()


func rodadaJogadorPrincipal() -> void:
	print("É a vez do jogador principal: ", jogador_principal.nome)
	await get_tree().create_timer(1.0).timeout
	await textDialog.show_dialog_with_text("É a vez do jogador %s" % jogador_principal.nome)
	await get_tree().create_timer(2.0).timeout
	await textDialog.hide_dialog()
	await get_tree().create_timer(1.0).timeout
	await textDialog.show_dialog_with_text("É a sua vez de jogar! Capture uma rota ou compre cartas.")
	pausar_jogador_principal = false
	pausar_cartas_mao_jogador_princial = false
	
	await acao_jogador_terminada # Espera até que o jogador principal finalize sua ação

	proximoTurno()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
