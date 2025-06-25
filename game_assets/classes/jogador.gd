class_name Jogador extends Node2D


var nome: String = "Jogador BOT"
var isBot: bool = false
var trens: int = 45
var pontos: int = 45
var cor: int = 0
var cartas: Array[GameCard] = []
var cartas_destino = []
var cartas_brancas: int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func adicionarCartaNaMao(cartaParaAdicionar: GameCard):
	if cartaParaAdicionar not in cartas and cartaParaAdicionar != null:
		cartas.append(cartaParaAdicionar)
		if cartaParaAdicionar.card_index == 7: # Cor Branca/Wildcard
			cartas_brancas += 1

func removerCartaDaMao(cartaParaRemover: GameCard):
	if cartaParaRemover in cartas:
		cartas.erase(cartaParaRemover)
		if cartaParaRemover.card_index == 7: # Cor Branca/Wildcard
			cartas_brancas -= 1
