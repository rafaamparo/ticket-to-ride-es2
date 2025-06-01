extends CanvasLayer
var card_manager: GerenciadorCartasJogador = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_manager = $"../GerenciadorCartasJogador"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	card_manager.gerarCartaAleatoria()
	pass # Replace with function body.
