class_name PlayerWinnerBox extends Control

signal response_received(result: int)

var player_ranking: Array[Jogador] = []
var show_dialog: bool = false
var btn_aceitar: Button = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await hide_dialog()  
	btn_aceitar = $Imagem/MarginContainer/VBoxContainer/VBoxContainer2/Button
	btn_aceitar.pressed.connect(_on_aceitar_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# function to show dialog, sets the dialog text and makes it visible using tween animation with fade in and scale effect
func show_dialog_box() -> void:
	show_dialog = true
	self.visible = true
	
	var winner_player_scene = preload("res://scenes/player_winner_box.tscn")
	
	
	for i in range(player_ranking.size()):
		var jogador = player_ranking[i]
		var player_box = winner_player_scene.instantiate()
	
		player_box.playerName = jogador.nome
		player_box.points = jogador.pontos
		player_box.ranking_position = i+1
		$"Imagem/MarginContainer/VBoxContainer/VencedoresContainer/Lista de Vencedores".add_child(player_box)
	
	var tween = create_tween()
	if tween:
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

# function to hide dialog, sets the dialog text to empty and makes it invisible using tween animation with fade out and scale effect
func hide_dialog() -> void:
	show_dialog = false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	self.visible = false
	
# function to toggle dialog visibility
func toggle_dialog() -> void:
	if show_dialog:
		await hide_dialog()
	else:
		await show_dialog_box()
		
func wait_for_response() -> int:
	var result = await response_received
	return result

func _on_aceitar_pressed() -> void:
	response_received.emit(1)
