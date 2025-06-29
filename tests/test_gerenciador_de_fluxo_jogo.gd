extends "res://addons/gut/test.gd"

var GerenciadorDeFluxo = load("res://scripts/gerenciador_de_fluxo_jogo.gd")
var GerenciadorComprarCartas = load("res://scripts/gerenciador_comprar_cartas.gd")
var TextDialog = load("res://scripts/text_dialog.gd")
var Jogador = load("res://game_assets/classes/jogador.gd")
var GameCardScene = load("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
var GameCard = load("res://scripts/game_card.gd")

var gerenciador_fluxo
var mock_comprar_cartas
var mock_text_dialog

func before_each():
	mock_comprar_cartas = double(GerenciadorComprarCartas).new()
	mock_text_dialog = double(TextDialog).new()
	stub(mock_text_dialog, "show_dialog_with_text").to_do_nothing()
	stub(mock_text_dialog, "hide_dialog").to_do_nothing()

	gerenciador_fluxo = GerenciadorDeFluxo.new()
	gerenciador_fluxo.configurar_para_teste(mock_comprar_cartas, mock_text_dialog)
	gerenciador_fluxo.lista_jogadores.clear()
	gerenciador_fluxo.lista_jogadores.append(Jogador.new())
	gerenciador_fluxo.lista_jogadores.append(Jogador.new())
	gerenciador_fluxo.jogador_do_turno = 0

func after_each():
	for jogador in gerenciador_fluxo.lista_jogadores:
		if is_instance_valid(jogador):
			jogador.free()
	gerenciador_fluxo.free()
	if mock_comprar_cartas:
		mock_comprar_cartas.free()
	if mock_text_dialog:
		mock_text_dialog.free()

func test_proximo_turno_avanca_jogador():
	print("Running test: test_proximo_turno_avanca_jogador")
	assert_eq(gerenciador_fluxo.jogador_do_turno, 0, "Initial turn should be 0")
	
	gerenciador_fluxo.proximoTurno()
	
	assert_eq(gerenciador_fluxo.jogador_do_turno, 1, "Turn should advance to 1")
	assert_called(mock_comprar_cartas, "atualizarTurnoLoja")
	print("Test passed: test_proximo_turno_avanca_jogador")

func test_proximo_turno_volta_para_o_inicio():
	print("Running test: test_proximo_turno_volta_para_o_inicio")
	gerenciador_fluxo.jogador_do_turno = 1
	
	gerenciador_fluxo.proximoTurno()
	
	assert_eq(gerenciador_fluxo.jogador_do_turno, 0, "Turn should wrap around to 0")
	assert_called(mock_comprar_cartas, "atualizarTurnoLoja")
	print("Test passed: test_proximo_turno_volta_para_o_inicio")

func test_encontrar_carta_util_na_loja_encontra_carta():
	print("Running test: test_encontrar_carta_util_na_loja_encontra_carta")
	var jogador = Jogador.new()
	var carta_jogador = GameCardScene.instantiate()
	carta_jogador.card_index = 3 # Blue
	jogador.cartas.append(carta_jogador)
	
	var carta_loja_util = GameCardScene.instantiate()
	carta_loja_util.card_index = 3 # Blue
	var carta_loja_inutil = GameCardScene.instantiate()
	carta_loja_inutil.card_index = 5 # Green
	var cartas_loja: Array[GameCard] = [carta_loja_inutil, carta_loja_util]
	
	var resultado = gerenciador_fluxo.encontrar_carta_util_na_loja(jogador, cartas_loja)
	
	assert_eq(resultado, carta_loja_util, "Should find the useful blue card")
	
	jogador.free()
	carta_jogador.free()
	carta_loja_util.free()
	carta_loja_inutil.free()
	print("Test passed: test_encontrar_carta_util_na_loja_encontra_carta")

func test_encontrar_carta_util_na_loja_sem_correspondencia():
	print("Running test: test_encontrar_carta_util_na_loja_sem_correspondencia")
	var jogador = Jogador.new()
	var carta_jogador = GameCardScene.instantiate()
	carta_jogador.card_index = 3 # Blue
	jogador.cartas.append(carta_jogador)
	
	var carta_loja_inutil = GameCardScene.instantiate()
	carta_loja_inutil.card_index = 5 # Green
	
	var cartas_loja: Array[GameCard] = [carta_loja_inutil]
	
	var resultado = gerenciador_fluxo.encontrar_carta_util_na_loja(jogador, cartas_loja)
	
	assert_null(resultado, "Should not find a useful card")

	# Cleanup
	jogador.free()
	carta_jogador.free()
	carta_loja_inutil.free()
	print("Test passed: test_encontrar_carta_util_na_loja_sem_correspondencia")

func test_bot_decide_capturar_rota_success():
	print("Running test: test_bot_decide_capturar_rota_success")
	var jogador_mock = double(Jogador).new()
	stub(jogador_mock, "capturarRotaBot").to_return(true)
	
	var resultado = await gerenciador_fluxo.bot_decide_capturar_rota(jogador_mock, null)
	
	assert_true(resultado, "Should return true when bot captures a route")
	assert_called(jogador_mock, "capturarRotaBot")
	print("Test passed: test_bot_decide_capturar_rota_success")

func test_bot_decide_capturar_rota_fail():
	print("Running test: test_bot_decide_capturar_rota_fail")
	var jogador_mock = double(Jogador).new()
	stub(jogador_mock, "capturarRotaBot").to_return(false)
	
	var resultado = await gerenciador_fluxo.bot_decide_capturar_rota(jogador_mock, null)
	
	assert_false(resultado, "Should return false when bot fails to capture a route")
	assert_called(jogador_mock, "capturarRotaBot")
	print("Test passed: test_bot_decide_capturar_rota_fail")
