class_name CartaDestino extends Node

var concluida: bool = false
var jogadorOwener: Jogador = null
var pontoInicio: Parada = null
var pontoFinal: Parada = null
var pontuacao: int = 0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func criar_carta(origem: Parada, destino: Parada, pontuacao_carta: int) -> CartaDestino:
	var carta_destino = CartaDestino.new()
	print(origem.nomeDaParada)
	print(destino.nomeDaParada)
	carta_destino.pontoInicio = origem
	carta_destino.pontoFinal = destino
	
	
	carta_destino.pontuacao = pontuacao_carta	
	if carta_destino.pontoInicio == null or carta_destino.pontoFinal == null:
		print("Erro: Origem ou destino inválido para a carta destino.")
		return null
	return carta_destino

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
