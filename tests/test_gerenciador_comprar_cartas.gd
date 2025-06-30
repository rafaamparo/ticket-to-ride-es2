extends "res://addons/gut/test.gd"

# This test script tests the GerenciadorComprarCartas logic in isolation.
# It creates new instances of the class for each test to avoid side effects.

func test_verificar_se_pode_comprar_carta_success():
	print("Running test: test_verificar_se_pode_comprar_carta_success")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	
	var carta = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn").instantiate()
	carta.card_index = randi_range(0,6) # Não é um joker
	
	var result = gerenciador.verificarSePodeComprarCarta(carta)
	
	assert_true(result, "Should be able to buy a regular card")
	
	# Cleanup
	carta.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_comprar_carta_success")

func test_verificar_se_pode_comprar_carta_fail_max_cards():
	print("Running test: test_verificar_se_pode_comprar_carta_fail_max_cards")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	
	var card1 = card_scene.instantiate()
	var card2 = card_scene.instantiate()
	gerenciador.cartas_compradas_turno_loja.append(card1)
	gerenciador.cartas_compradas_turno_loja.append(card2)
	
	var carta_a_comprar = card_scene.instantiate()
	var result = gerenciador.verificarSePodeComprarCarta(carta_a_comprar)
	
	assert_false(result, "Should not be able to buy more than max cards")
	
	# Cleanup
	card1.free()
	card2.free()
	carta_a_comprar.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_comprar_carta_fail_max_cards")

func test_verificar_se_pode_comprar_joker_fail():
	print("Running test: test_verificar_se_pode_comprar_joker_fail")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")

	var carta_normal = card_scene.instantiate()
	carta_normal.card_index = randi_range(0,6)
	gerenciador.cartas_compradas_turno_loja.append(carta_normal)

	var joker_card = card_scene.instantiate()
	joker_card.card_index = 7 # Joker card
	
	var result = gerenciador.verificarSePodeComprarCarta(joker_card)
	
	assert_false(result, "Should not be able to buy joker if another card was already bought")
	
	# Cleanup
	carta_normal.free()
	joker_card.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_comprar_joker_fail")

func test_verificar_se_pode_pegar_do_baralho_success():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_success")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	
	var result = gerenciador.verificarSePodePegarDoBaralho()
	
	assert_true(result, "Should be able to take from deck")
	
	# Cleanup
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_success")

func test_verificar_se_pode_pegar_do_baralho_fail_max_cards():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_fail_max_cards")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")

	var card1 = card_scene.instantiate()
	var card2 = card_scene.instantiate()
	gerenciador.cartas_compradas_turno_baralho.append(card1)
	gerenciador.cartas_compradas_turno_baralho.append(card2)
	
	var result = gerenciador.verificarSePodePegarDoBaralho()
	
	assert_false(result, "Should not be able to take from deck if max cards reached")
	
	# Cleanup
	card1.free()
	card2.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_fail_max_cards")

func test_comprar_carta_do_baralho():
	print("Running test: test_comprar_carta_do_baralho")
	var gerenciador = GerenciadorComprarCartas.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var jogador = load("res://game_assets/classes/jogador.gd").new()
	
	gerenciador.comprarCartaDoBaralho(jogador)
	
	assert_eq(jogador.cartas.size(), 1, "Player should have 1 card")
	assert_eq(gerenciador.cartas_compradas_turno_baralho.size(), 1, "Deck purchase count should be 1")
	
	# Cleanup
	var card_in_array = gerenciador.cartas_compradas_turno_baralho[0]
	card_in_array.free()
	
	gerenciador.free()
	jogador.free()
	print("Test passed: test_comprar_carta_do_baralho")

func test_verificar_se_pode_pegar_do_baralho_destino_success():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_destino_success")
	var gerenciador = GerenciadorComprarCartas.new()
	
	var result = gerenciador.verificarSePodePegarDoBaralhoDestino()
	
	assert_true(result, "Should be able to take from destination deck")
	
	# Cleanup
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_destino_success")

func test_verificar_se_pode_pegar_do_baralho_destino_fail():
	print("Running test: test_verificar_se_pode_pegar_do_baralho_destino_fail")
	var gerenciador = GerenciadorComprarCartas.new()
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	
	var card1 = card_scene.instantiate()
	gerenciador.cartas_compradas_turno_loja.append(card1)
	
	var result = gerenciador.verificarSePodePegarDoBaralhoDestino()
	
	assert_false(result, "Should not be able to take from destination deck if a card was already bought")
	
	# Cleanup
	card1.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_pode_pegar_do_baralho_destino_fail")

func test_verificar_se_jogador_finalizou_acao_max_cards():
	print("Running test: test_verificar_se_jogador_finalizou_acao_max_cards")
	var gerenciador = GerenciadorComprarCartas.new()
	var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
	gerenciador.gerenciadorFluxoDeJogo = GerenciadorDeFluxo.new()
	gerenciador.gerenciadorFluxoDeJogo.pausar_jogador_principal = false
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	
	var card1 = card_scene.instantiate()
	var card2 = card_scene.instantiate()
	gerenciador.cartas_compradas_turno_loja.append(card1)
	gerenciador.cartas_compradas_turno_loja.append(card2)
	
	var result = gerenciador.verificarSeJogadorFinalizouAcao()
	
	assert_true(result, "Should have finished action after buying max cards")
	
	# Cleanup
	card1.free()
	card2.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_jogador_finalizou_acao_max_cards")

func test_verificar_se_jogador_finalizou_acao_joker():
	print("Running test: test_verificar_se_jogador_finalizou_acao_joker")
	var gerenciador = GerenciadorComprarCartas.new()
	var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
	gerenciador.gerenciadorFluxoDeJogo = GerenciadorDeFluxo.new()
	gerenciador.gerenciadorFluxoDeJogo.pausar_jogador_principal = false
	var card_scene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	
	var joker_card = card_scene.instantiate()
	joker_card.card_index = 7 # Joker card
	gerenciador.cartas_compradas_turno_loja.append(joker_card)
	
	var result = gerenciador.verificarSeJogadorFinalizouAcao()
	
	assert_true(result, "Should have finished action after buying a joker card")
	
	# Cleanup
	joker_card.free()
	gerenciador.free()
	print("Test passed: test_verificar_se_jogador_finalizou_acao_joker")

func test_verificar_se_jogador_nao_finalizou_acao():
	print("Running test: test_verificar_se_jogador_nao_finalizou_acao")
	var gerenciador = GerenciadorComprarCartas.new()
	var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
	gerenciador.gerenciadorFluxoDeJogo = GerenciadorDeFluxo.new()
	gerenciador.gerenciadorFluxoDeJogo.pausar_jogador_principal = false
	
	var result = gerenciador.verificarSeJogadorFinalizouAcao()
	
	assert_false(result, "Should not have finished action with no cards bought")
	
	# Cleanup
	gerenciador.free()
	print("Test passed: test_verificar_se_jogador_nao_finalizou_acao")
