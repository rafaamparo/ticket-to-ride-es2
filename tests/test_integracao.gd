extends "res://addons/gut/test.gd"

# Integration tests for overall game flow (GerenciadorDeFluxo)

var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
var GerenciadorComprarCartas = load("res://scripts/gerenciador_comprar_cartas.gd")
var GerenciadorCartasDestino = load("res://scripts/gerenciador_cartas_destino.gd")
var TextDialog = load("res://scripts/text_dialog.gd")
var Jogador = load("res://game_assets/classes/jogador.gd")
var GameCardScene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")

var gerenciador_fluxo
var mock_compra
var mock_destino
var mock_text

func before_each():
	# Stub dependencies
	mock_compra = double(GerenciadorComprarCartas).new()
	stub(mock_compra, "atualizarTurnoLoja").to_do_nothing()

	mock_destino = double(GerenciadorCartasDestino).new()
	stub(mock_destino, "atualizarTurnoDestino").to_do_nothing()

	mock_text = double(TextDialog).new()
	stub(mock_text, "show_dialog_with_text").to_do_nothing()
	stub(mock_text, "hide_dialog").to_do_nothing()

	# Initialize fluxo manager for testing
	gerenciador_fluxo = GerenciadorDeFluxo.new()
	gerenciador_fluxo.configurar_para_teste(mock_compra, mock_text)
	gerenciador_fluxo.gerenciadorDeCartasDestino = mock_destino
	# Setup two players
	gerenciador_fluxo.lista_jogadores.clear()
	gerenciador_fluxo.lista_jogadores.append(Jogador.new())
	gerenciador_fluxo.lista_jogadores.append(Jogador.new())
	gerenciador_fluxo.jogador_do_turno = 0

func after_each():
	gerenciador_fluxo.free()

func test_integration_proximo_turno_triggers_managers():
	print("Running integration test: proximoTurno triggers card managers")
	gerenciador_fluxo.proximoTurno()
	assert_eq(gerenciador_fluxo.jogador_do_turno, 1, "Turn should advance to next player")
	assert_called(mock_compra, "atualizarTurnoLoja")
	assert_called(mock_destino, "atualizarTurnoDestino")
	print("Test passed: proximoTurno triggers card managers")

func test_integration_encontrar_carta_util_na_loja():
	print("Running integration test: encontrar_carta_util_na_loja")
	# Use real GerenciadorComprarCartas to supply store cards
	var ger_compras = GerenciadorComprarCartas.new()
	# Prepare store: one red (index=2), one blue (index=3)
	var red_card = GameCardScene.instantiate(); red_card.card_index = 2
	var blue_card = GameCardScene.instantiate(); blue_card.card_index = 3
	# Setup store list without direct assignment
	ger_compras.cartas_da_loja.clear()
	ger_compras.cartas_da_loja.append(red_card)
	ger_compras.cartas_da_loja.append(blue_card)
	# Bot has one blue card
	var jogador = Jogador.new()
	var own_blue = GameCardScene.instantiate(); own_blue.card_index = 3
	jogador.cartas.append(own_blue)

	var result = gerenciador_fluxo.encontrar_carta_util_na_loja(jogador, ger_compras.cartas_da_loja)
	assert_eq(result, blue_card, "Should pick the blue card the bot already has")
	# Cleanup
	red_card.free()
	blue_card.free()
	own_blue.free()
	ger_compras.free()
	jogador.free()
	print("Test passed: encontrar_carta_util_na_loja")

func test_integration_verificar_se_algum_jogador_venceu():
	print("Running integration test: verificarSeAlgumJogadorVenceu")
	gerenciador_fluxo.lista_jogadores[0].trens = 1
	gerenciador_fluxo.lista_jogadores[1].trens = 5
	assert_true(gerenciador_fluxo.verificarSeAlgumJogadorVenceu(), "Should detect game end when a player has <=2 trains")
	print("Test passed: verificarSeAlgumJogadorVenceu")

# Integration tests for GerenciadorComprarCartas purchase flow
func test_integration_comprar_duas_cartas_do_baralho() -> void:
	print("Running integration test: comprar duas cartas do baralho")
	var gerenciador = GerenciadorComprarCartas.new()
	# initialize real managers
	gerenciador.gerenciadorFluxoDeJogo = GerenciadorDeFluxo.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var jogador = Jogador.new()

	gerenciador.comprarCartaDoBaralho(jogador)
	gerenciador.comprarCartaDoBaralho(jogador)

	assert_eq(jogador.cartas.size(), 2, "Jogador deve ter 2 cartas após duas compras do baralho")
	assert_eq(gerenciador.cartas_compradas_turno_baralho.size(), 2, "Gerenciador deve contar 2 compras no turno")
	
	# Cleanup
	jogador.free()
	gerenciador.free()
	print("Test passed: comprar duas cartas do baralho")

func test_integration_nao_pode_comprar_terceira_carta_do_baralho() -> void:
	print("Running integration test: não pode comprar terceira carta do baralho")
	var gerenciador = GerenciadorComprarCartas.new()
	# initialize real managers
	gerenciador.gerenciadorFluxoDeJogo = GerenciadorDeFluxo.new()
	gerenciador.gerenciador_de_cartas_destino = GerenciadorCartasDestino.new()
	var jogador = Jogador.new()

	gerenciador.comprarCartaDoBaralho(jogador)
	gerenciador.comprarCartaDoBaralho(jogador)
	gerenciador.comprarCartaDoBaralho(jogador)

	assert_eq(jogador.cartas.size(), 2, "Jogador não deve ter mais de 2 cartas do baralho em um turno")
	assert_eq(gerenciador.cartas_compradas_turno_baralho.size(), 2, "Gerenciador não deve contar mais de 2 compras no turno")
	
	# Cleanup
	jogador.free()
	gerenciador.free()
	print("Test passed: não pode comprar terceira carta do baralho")
