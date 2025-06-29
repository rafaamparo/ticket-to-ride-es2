extends Node

# Mock objects for dependencies
var mock_text_dialog
var mock_gerenciador_comprar_cartas
var mock_gerenciador_cartas_jogador
var mock_box_jogadores_container

# The instance of the class we are testing
var gerenciador_de_fluxo

func before_each():
	# Set up the test environment
	gerenciador_de_fluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd").new()
	
	# Create mock objects
	mock_text_dialog = Node.new()
	mock_text_dialog.add_user_signal("show_dialog_with_text")
	mock_text_dialog.add_user_signal("hide_dialog")
	
	mock_gerenciador_comprar_cartas = Node.new()
	mock_gerenciador_cartas_jogador = Node.new()
	mock_box_jogadores_container = Node.new()
	
	# Assign mocks to the gerenciador
	gerenciador_de_fluxo.textDialog = mock_text_dialog
	gerenciador_de_fluxo.gerenciadorDeComprarCartas = mock_gerenciador_comprar_cartas
	
	# Mock the get_node calls
	# This is a simplified approach. A real test framework might offer better ways to do this.
	var gui_node = Node.new()
	gui_node.name = "GUI"
	gerenciador_de_fluxo.add_child(gui_node)
	
	var text_dialog_node = mock_text_dialog
	text_dialog_node.name = "TextDialog"
	gui_node.add_child(text_dialog_node)
	
	var comprar_cartas_node = mock_gerenciador_comprar_cartas
	comprar_cartas_node.name = "GerenciadorComprarCartas"
	gui_node.add_child(comprar_cartas_node)
	
	var gerenciador_cartas_node = mock_gerenciador_cartas_jogador
	gerenciador_cartas_node.name = "GerenciadorCartasJogador"
	gerenciador_de_fluxo.add_child(gerenciador_cartas_node)
	
	var box_container_node = mock_box_jogadores_container
	box_container_node.name = "BoxJogadoresContainer"
	gui_node.add_child(box_container_node)
	
	# Add child nodes so get_node works
	gerenciador_de_fluxo.call_deferred("add_child", gui_node)


func test_initial_player_setup():
	print("Running test: test_initial_player_setup")
	# Run the setup method
	gerenciador_de_fluxo._ready()
	
	# Assertions
	assert(gerenciador_de_fluxo.lista_jogadores.size() == 4, "Should have 4 players")
	assert(gerenciador_de_fluxo.jogador_principal != null, "Main player should exist")
	assert(gerenciador_de_fluxo.jogador_principal.isBot == false, "Main player should not be a bot")
	
	var bot_count = 0
	for jogador in gerenciador_de_fluxo.lista_jogadores:
		if jogador.isBot:
			bot_count += 1
	assert(bot_count == 3, "Should have 3 bot players")
	print("Test passed: test_initial_player_setup")

func test_proximo_turno():
	print("Running test: test_proximo_turno")
	gerenciador_de_fluxo._ready() # To initialize players
	gerenciador_de_fluxo.jogador_do_turno = 0
	gerenciador_de_fluxo.proximoTurno()
	assert(gerenciador_de_fluxo.jogador_do_turno == 1, "Turn should advance to player 1")
	
	gerenciador_de_fluxo.jogador_do_turno = 3
	gerenciador_de_fluxo.proximoTurno()
	assert(gerenciador_de_fluxo.jogador_do_turno == 0, "Turn should wrap around to player 0")
	print("Test passed: test_proximo_turno")

func test_encontrar_carta_util_na_loja_success():
	print("Running test: test_encontrar_carta_util_na_loja_success")
	var jogador = load("res://game_assets/classes/jogador.gd").new()
	var carta_jogador = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta_jogador.card_index = 2 # Blue
	jogador.cartas.append(carta_jogador)
	
	var cartas_loja = []
	var carta_loja_util = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta_loja_util.card_index = 2 # Blue
	cartas_loja.append(carta_loja_util)
	
	var carta_encontrada = gerenciador_de_fluxo.encontrar_carta_util_na_loja(jogador, cartas_loja)
	assert(carta_encontrada != null, "Should find a useful card")
	assert(carta_encontrada.card_index == 2, "Should find the blue card")
	print("Test passed: test_encontrar_carta_util_na_loja_success")

func test_encontrar_carta_util_na_loja_fail():
	print("Running test: test_encontrar_carta_util_na_loja_fail")
	var jogador = load("res://game_assets/classes/jogador.gd").new()
	var carta_jogador = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta_jogador.card_index = 2 # Blue
	jogador.cartas.append(carta_jogador)
	
	var cartas_loja = []
	var carta_loja_inutil = load("res://game_assets/game_scene/object_scenes/game_card.gd").new()
	carta_loja_inutil.card_index = 3 # Red
	cartas_loja.append(carta_loja_inutil)
	
	var carta_encontrada = gerenciador_de_fluxo.encontrar_carta_util_na_loja(jogador, cartas_loja)
	assert(carta_encontrada == null, "Should not find a useful card")
	print("Test passed: test_encontrar_carta_util_na_loja_fail")


func run_tests():
	before_each()
	test_initial_player_setup()
	before_each()
	test_proximo_turno()
	before_each()
	test_encontrar_carta_util_na_loja_success()
	before_each()
	test_encontrar_carta_util_na_loja_fail()
