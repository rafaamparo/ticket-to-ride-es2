class_name JogadorBotBox extends Control


var jogadorSelecionado: Jogador = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Nome.text = jogadorSelecionado.nome;
	$bilhetes.text = str(len(jogadorSelecionado.cartas_destino))
	$pontos.text = str(jogadorSelecionado.trens)
	pass
