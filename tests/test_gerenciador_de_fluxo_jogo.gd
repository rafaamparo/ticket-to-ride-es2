extends "res://addons/gut/test.gd"

# Preload scripts and scenes needed for the tests
var Jogador = load("res://game_assets/classes/jogador.gd")
var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
var GerenciadorComprarCartas = load("res://scripts/gerenciador_comprar_cartas.gd")
var GameCard = load("res://scripts/loja_cartas_container.gd") # Carregando a classe GameCard

# --- Test proximoTurno ---
# This test checks if the turn advances correctly.
func test_proximo_turno_advances_and_wraps_around():
	print("Running test: test_proximo_turno_advances_and_wraps_around")
	# Setup
	var gerenciador = GerenciadorDeFluxo.new()
	
	# Create a mock for the dependency
	var mock_comprar_cartas = double(GerenciadorComprarCartas).new()
	stub(mock_comprar_cartas, "atualizarTurnoLoja").to_do_nothing()
	
	# Configure the object for testing, injecting the mock
	gerenciador.configurar_para_teste(mock_comprar_cartas, null)
	
	# Create 4 dummy players
	for i in 4:
		var p = Jogador.new()
		gerenciador.lista_jogadores.append(p)
	
	# --- Test 1: Advance from 0 to 1 ---
	gerenciador.jogador_do_turno = 0
	gerenciador.proximoTurno()
	assert_eq(gerenciador.jogador_do_turno, 1, "Turn should advance from 0 to 1")

	# --- Test 2: Advance from 3 to 0 (wrap around) ---
	gerenciador.jogador_do_turno = 3
	gerenciador.proximoTurno()
	assert_eq(gerenciador.jogador_do_turno, 0, "Turn should wrap around from 3 to 0")

	# Cleanup
	for p in gerenciador.lista_jogadores:
		p.free()
	gerenciador.free()
	print("Test passed: test_proximo_turno_advances_and_wraps_around")


# --- Tests for encontrar_carta_util_na_loja ---
func test_encontrar_carta_util_success():
	print("Running test: test_encontrar_carta_util_success")
	# Setup
	var gerenciador = GerenciadorDeFluxo.new()
	var jogador = Jogador.new()

	# Give the player a blue card (index 2)
	var player_card = GameCard.new()
	player_card.card_index = 2
	jogador.cartas.append(player_card)
	
	# Create a shop with a red card and a blue card
	var shop_cards = []
	var red_card = GameCard.new()
	red_card.card_index = 3
	var blue_card = GameCard.new()
	blue_card.card_index = 2
	shop_cards.append(red_card)
	shop_cards.append(blue_card)
	
	# Execute
	var found_card = gerenciador.encontrar_carta_util_na_loja(jogador, shop_cards)
	
	# Assert
	assert_is(found_card, blue_card, "Should find the useful blue card")
	
	# Cleanup
	jogador.free()
	gerenciador.free()
	print("Test passed: test_encontrar_carta_util_success")


func test_encontrar_carta_util_fail_no_useful_card():
	print("Running test: test_encontrar_carta_util_fail_no_useful_card")
	# Setup
	var gerenciador = GerenciadorDeFluxo.new()
	var jogador = Jogador.new()

	# Give the player a blue card (index 2)
	var player_card = GameCard.new()
	player_card.card_index = 2
	jogador.cartas.append(player_card)
	
	# Create a shop with only a red card
	var shop_cards = []
	var red_card = GameCard.new()
	red_card.card_index = 3
	shop_cards.append(red_card)
	
	# Execute
	var found_card = gerenciador.encontrar_carta_util_na_loja(jogador, shop_cards)
	
	# Assert
	assert_null(found_card, "Should not find a useful card")
	
	# Cleanup
	jogador.free()
	gerenciador.free()
	print("Test passed: test_encontrar_carta_util_fail_no_useful_card")


func test_encontrar_carta_util_fail_empty_shop():
	print("Running test: test_encontrar_carta_util_fail_empty_shop")
	# Setup
	var gerenciador = GerenciadorDeFluxo.new()
	var jogador = Jogador.new()

	# Give the player a blue card
	var player_card = GameCard.new()
	player_card.card_index = 2
	jogador.cartas.append(player_card)
	
	# Shop is empty
	var shop_cards = []
	
	# Execute
	var found_card = gerenciador.encontrar_carta_util_na_loja(jogador, shop_cards)
	
	# Assert
	assert_null(found_card, "Should return null for an empty shop")
	
	# Cleanup
	jogador.free()
	gerenciador.free()
	print("Test passed: test_encontrar_carta_util_fail_empty_shop")
