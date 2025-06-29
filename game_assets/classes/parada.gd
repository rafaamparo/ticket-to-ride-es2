class_name Parada extends Node


@export var nomeDaParada: String = ""
@export var caminhos: Array[TrilhaVagao] = []
var gerenciadorDeTrilhas: GerenciadorDeTrilhas = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerenciadorDeTrilhas = $"../../GerenciadorDeTrilhas";
	var todas_as_trilhas: Array[TrilhaVagao] = gerenciadorDeTrilhas.lista_trilhas

	# Considerando que Paradas e Trilhas formam um grafo bidirectional, quero preencher o array de caminhos. Considere que cada trilha na lista de todas_as_trilhas possui a propriedade 'parada1' e 'parada2' que referenciam as paradas conectadas.
	# Uma parada pode ter várias trilhas conectadas
	for trilha in todas_as_trilhas:
		if trilha.parada1 == self or trilha.parada2 == self:
			caminhos.append(trilha)

	# Agora, printe o nome da parada e as trilhas conectadas a ela
	print("Parada: ", nomeDaParada)
	for trilha in caminhos:
		print("  Trilha: ", trilha, " - Cor: ", trilha.cor_trilha, " - Capturada: ", trilha.capturado)
			
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
