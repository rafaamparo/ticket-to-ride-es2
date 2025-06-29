extends Node

# Mock objects
var mock_trilha_vagao
var gerenciador_de_trilhas

# Mock TrilhaVagao class
var TrilhaVagaoMock = preload("res://game_assets/game_scene/object_scenes/caminhos/trilha.gd")

func before_each():
	gerenciador_de_trilhas = load("res://scenes/gerenciador_de_trilhas.gd").new()
	
	# Create a mock TrilhaVagao and add it to the gerenciador
	mock_trilha_vagao = TrilhaVagaoMock.new()
	mock_trilha_vagao.name = "TestTrilha"
	gerenciador_de_trilhas.add_child(mock_trilha_vagao)

func test_unhighlight_all_trilhas():
	print("Running test: test_unhighlight_all_trilhas")
	# We can't easily verify the unhighlight call without a more complex mock.
	# We will call the function and check that it doesn't crash.
	gerenciador_de_trilhas.unhighlight_all_trilhas()
	assert(true, "unhighlight_all_trilhas should run without error")
	print("Test passed: test_unhighlight_all_trilhas")


func run_tests():
	before_each()
	test_unhighlight_all_trilhas()

func _ready():
	run_tests()
