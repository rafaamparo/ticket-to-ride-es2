extends Node

func _ready() -> void:
	print("--- Running All Tests ---")
	
	var test_fluxo = load("res://tests/test_gerenciador_de_fluxo_jogo.gd").new()
	test_fluxo.run_tests()
	
	var test_comprar_cartas = load("res://tests/test_gerenciador_comprar_cartas.gd").new()
	test_comprar_cartas.run_tests()

	var test_trilhas = load("res://tests/test_gerenciador_de_trilhas.gd").new()
	test_trilhas.run_tests()
	
	print("--- All Tests Finished ---")
	get_tree().quit() # Optional: quit the game after tests run
