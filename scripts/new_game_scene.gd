extends Control


var start_button = null
var input_qtd_bots = null
var input_dificuldade = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button = $MarginContainer/VBoxContainer2/HBoxContainer2/Panel/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button
	input_qtd_bots = $MarginContainer/VBoxContainer2/HBoxContainer2/Panel/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/OptionButton
	input_dificuldade = $MarginContainer/VBoxContainer2/HBoxContainer2/Panel/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var valorSelecionado = input_qtd_bots.get_selected_id()
	var input_dificuldade = input_dificuldade.get_selected_id()

	if valorSelecionado == -1 or input_dificuldade == -1:
		start_button.disabled = true
	else:
		start_button.disabled = false


func _on_button_pressed() -> void:
	Globals.qtd_bots = input_qtd_bots.get_selected_id()
	Globals.dificuldade = input_dificuldade.get_selected_id()
	
	if (input_dificuldade.get_selected_id() == 0):
		Globals.qtd_trens_inicio = 14
		Globals.qtd_cartas_inicio = 8
	
	if (input_dificuldade.get_selected_id() == 1):
		Globals.qtd_trens_inicio = 30
		Globals.qtd_cartas_inicio = 6
		
	if (input_dificuldade.get_selected_id() == 2):
		Globals.qtd_trens_inicio = 30
		Globals.qtd_cartas_inicio = 3
	
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
