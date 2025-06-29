extends Node

var gerenciador_comprar_cartas
var mock_fluxo_jogo
var mock_loja_cartas_container

func before_each():
	gerenciador_comprar_cartas = load("res://scripts/gerenciador_comprar_cartas.gd").new()
	
	mock_fluxo_jogo = Node.new()
	mock_fluxo_jogo.pausar_jogador_principal = false
	
	mock_loja_cartas_container = Node.new()
	
	gerenciador_comprar_cartas.gerenciadorFluxoDeJogo = mock_fluxo_jogo
	gerenciador_comprar_cartas.add_child(mock_loja_cartas_container)
	mock_loja_cartas_container.name = "LojaCartasContainer"

func test_verificar_se_pode_comprar_carta_success():
	print("Running test: test_verificar_se_pode_comprar_carta_success")
	var carta = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta.card_index = 1 # Not a joker
	
	var result = gerenciador_comprar_cartas.verificarSePodeComprarCarta(carta)
	
	assert(result == true, "Should be able to buy a regular card")
	print("Test passed: test_verificar_se_pode_comprar_carta_success")

func test_verificar_se_pode_comprar_carta_fail_max_cards():
	print("Running test: test_verificar_se_pode_comprar_carta_fail_max_cards")
	gerenciador_comprar_cartas.cartas_compradas_turno_loja.append(Node.new())
	gerenciador_comprar_cartas.cartas_compradas_turno_loja.append(Node.new())
	
	var carta = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	var result = gerenciador_comprar_cartas.verificarSePodeComprarCarta(carta)
	
	assert(result == false, "Should not be able to buy more than max cards")
	print("Test passed: test_verificar_se_pode_comprar_carta_fail_max_cards")

func test_verificar_se_pode_comprar_joker_fail():
	print("Running test: test_verificar_se_pode_comprar_joker_fail")
	var carta_normal = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta_normal.card_index = 1
	gerenciador_comprar_cartas.cartas_compradas_turno_loja.append(carta_normal)

	var joker_card = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	joker_card.card_index = 7 # Joker card
	
	var result = gerenciador_comprar_cartas.verificarSePodeComprarCarta(joker_card)
	
	assert(result == false, "Should not be able to buy joker if another card was already bought")
	print("Test passed: test_verificar_se_pode_comprar_joker_fail")

func test_verificar_se_pode_pegar_do_baralho_success():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_success")
	var result = gerenciador_comprar_cartas.verificarSePodePegarDoBaralho()
	assert(result == true, "Should be able to take from deck")
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_success")

func test_verificar_se_pode_pegar_do_baralho_fail_max_cards():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_fail_max_cards")
	gerenciador_comprar_cartas.cartas_compradas_turno_baralho.append(Node.new())
	gerenciador_comprar_cartas.cartas_compradas_turno_baralho.append(Node.new())
	var result = gerenciador_comprar_cartas.verificarSePodePegarDoBaralho()
	assert(result == false, "Should not be able to take from deck if max cards reached")
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_fail_max_cards")

func test_comprar_carta_do_baralho():
	print("Running test: test_comprar_carta_do_baralho")
	var jogador = load("res://game_assets/classes/jogador.gd").new()
	gerenciador_comprar_cartas.comprarCartaDoBaralho(jogador)
	assert(jogador.cartas.size() == 1, "Player should have 1 card")
	assert(gerenciador_comprar_cartas.cartas_compradas_turno_baralho.size() == 1, "Deck purchase count should be 1")
	print("Test passed: test_comprar_carta_do_baralho")

func run_tests():
	before_each()
	test_verificar_se_pode_comprar_carta_success()
	before_each()
	test_verificar_se_pode_comprar_carta_fail_max_cards()
	before_each()
	test_verificar_se_pode_comprar_joker_fail()
	before_each()
	test_verificar_se_pode_pegar_do_baralho_success()
	before_each()
	test_verificar_se_pode_pegar_do_baralho_fail_max_cards()
	before_each()
	test_comprar_carta_do_baralho()

func _ready():
	run_tests()
