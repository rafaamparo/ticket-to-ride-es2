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
	
	# Cleanup
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
	jogador_mock.free()
	print("Test passed: test_bot_decide_capturar_rota_success")

func test_bot_decide_capturar_rota_fail():
	print("Running test: test_bot_decide_capturar_rota_fail")
	var jogador_mock = double(Jogador).new()
	stub(jogador_mock, "capturarRotaBot").to_return(false)
	
	var resultado = await gerenciador_fluxo.bot_decide_capturar_rota(jogador_mock, null)
	
	assert_false(resultado, "Should return false when bot fails to capture a route")
	assert_called(jogador_mock, "capturarRotaBot")
	jogador_mock.free()
	print("Test passed: test_bot_decide_capturar_rota_fail")

func test_verificar_se_jogador_venceu_true():
	print("Running test: test_verificar_se_jogador_venceu_true")
	gerenciador_fluxo.lista_jogadores[0].trens = 2
	var resultado = gerenciador_fluxo.verificarSeAlgumJogadorVenceu()
	assert_true(resultado, "Should return true when a player has 2 trains")
	print("Test passed: test_verificar_se_jogador_venceu_true")

func test_verificar_se_jogador_venceu_false():
	print("Running test: test_verificar_se_jogador_venceu_false")
	gerenciador_fluxo.lista_jogadores[0].trens = 3
	gerenciador_fluxo.lista_jogadores[1].trens = 5
	var resultado = gerenciador_fluxo.verificarSeAlgumJogadorVenceu()
	assert_false(resultado, "Should return false when no player has 2 or fewer trains")
	print("Test passed: test_verificar_se_jogador_venceu_false")

func test_bot_decide_compra_para_ao_comprar_coringa_da_loja():
	print("Running test: test_bot_decide_compra_para_ao_comprar_coringa_da_loja")
	var jogador = Jogador.new()
	var coringa = GameCardScene.instantiate()
	coringa.card_index = 7 # Coringa

	stub(mock_comprar_cartas, "verificarSePodeComprarCarta").to_return(true)
	stub(mock_comprar_cartas, "comprarCartaDaLoja").to_return_nothing()
	
	# Simula que a loja tem um coringa
	mock_comprar_cartas.cartas_da_loja = [coringa]
	# Simula que o coringa foi comprado
	mock_comprar_cartas.cartas_compradas_turno_loja = [coringa]

	await gerenciador_fluxo.bot_decide_compra(jogador)

	# O bot deve comprar apenas uma carta (o coringa) e parar.
	assert_call_count(mock_comprar_cartas, "comprarCartaDaLoja", 1, "Should have called comprarCartaDaLoja only once for the wildcard")
	
	jogador.free()
	coringa.free()
	print("Test passed: test_bot_decide_compra_para_ao_comprar_coringa_da_loja")

func test_bot_decide_compra_para_ao_comprar_carta_normal():
    print("Running test: test_bot_decide_compra_para_ao_comprar_carta
_normal")
    var jogador = Jogador.new()
    var carta_normal = GameCardScene.instantiate()
    carta_normal.card_index = 1 # Not a joker
    stub(mock_comprar_cartas, "verificarSePodeComprarCarta").to_return(true)
    stub(mock_comprar_cartas, "comprarCartaDaLoja").to_return_nothing() 
    # Simula que a loja tem uma carta normal
    mock_comprar_cartas.cartas_da_loja = [carta_normal]
    # Simula que a carta normal foi comprada
    mock_comprar_cartas.cartas_compradas_turno_loja = [carta_normal]
    await gerenciador_fluxo.bot_decide_compra(jogador)
    # O bot deve comprar apenas uma carta (a normal) e parar.
    assert_call_count(mock_comprar_cartas, "comprarCartaDaLoja",

    1, "Should have called comprarCartaDaLoja only once for the normal card")
    jogador.free()
    carta_normal.free()
    print("Test passed: test_bot_decide_compra_para_ao_comprar_carta_normal")

func test_bot_decide_compra_para_ao_nao_comprar_carta():
    print("Running test: test_bot_decide_compra_para_ao_nao_comprar_carta")
    var jogador = Jogador.new()
    stub(mock_comprar_cartas, "verificarSePodeComprarCarta").to_return(false)
    stub(mock_comprar_cartas, "comprarCartaDaLoja").to_return_nothing()
    # Simula que a loja não tem cartas disponíveis
    mock_comprar_cartas.cartas_da_loja = []
    mock_comprar_cartas.cartas_compradas_turno_loja = []
    await gerenciador_fluxo.bot_decide_compra(jogador)
    # O bot não deve tentar comprar nenhuma carta
    assert_call_count(mock_comprar_cartas, "comprarCartaDaLoja",
    0, "Should not have called comprarCartaDaLoja when no cards are available")
    jogador.free()
    print("Test passed: test_bot_decide_compra_para_ao_nao_comprar_carta")
    