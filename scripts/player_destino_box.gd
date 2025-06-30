class_name PLayerDestinoDialog extends Control

signal response_received(result: int)

var show_dialog: bool = false
var parada1_label: Label = null
var parada2_label: Label = null
var pontuacao_label: Label = null
var btn_recusar: Button = null
var btn_aceitar: Button = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn_recusar = $Imagem/MarginContainer/VBoxContainer/VBoxContainer2/Recusar
	btn_aceitar = $Imagem/MarginContainer/VBoxContainer/VBoxContainer2/Aceitar
	btn_aceitar.pressed.connect(_on_aceitar_pressed)
	btn_recusar.pressed.connect(_on_recusar_pressed)
	parada1_label = $"Imagem/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/DadosDeCartaBox/Lista de Atributos/Dados_Text";
	parada2_label = $"Imagem/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/DadosDeCartaBox/Lista de Atributos/Dados_Text2"
	pontuacao_label = $"Imagem/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/DadosDeCartaBox/Lista de Atributos/Dados_Text3"
	await hide_dialog()  
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# function to show dialog, sets the dialog text and makes it visible using tween animation with fade in and scale effect
func show_dialog_box(carta_destino: CartaDestino = null, forceAccept: bool = false) -> void:
	show_dialog = true
	
	btn_aceitar.show()
	btn_recusar.show()
	btn_recusar.disabled = forceAccept

	parada1_label.text = "Parada 1: " + (carta_destino.pontoInicio.nomeDaParada if carta_destino else "Parada 1")
	parada2_label.text = "Parada 2: " + (carta_destino.pontoFinal.nomeDaParada if carta_destino else "Parada 2")
	pontuacao_label.text = "Pontuação: " + str(carta_destino.pontuacao if carta_destino else 0)

	var tween = create_tween()
	if tween:
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

# function to hide dialog, sets the dialog text to empty and makes it invisible using tween animation with fade out and scale effect
func hide_dialog() -> void:
	show_dialog = false
	btn_recusar.disabled = false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
# function to toggle dialog visibility
func toggle_dialog() -> void:
	if show_dialog:
		await hide_dialog()
	else:
		await show_dialog_box()

# function to wait for user response from the buttons
func wait_for_response() -> int:
	var result = await response_received
	return result

func _on_aceitar_pressed() -> void:
	response_received.emit(1)

func _on_recusar_pressed() -> void:
	response_received.emit(0)
