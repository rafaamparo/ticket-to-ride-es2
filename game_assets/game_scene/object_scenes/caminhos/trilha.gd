class_name TrilhaVagao extends Node2D

const cores_map = {
	"vermelho": 0,
	"amarelo": 1,
	"azul": 2,
	"roxo": 3,
	"laranja": 4,
	"preto": 5,
	"verde": 6,
	"cinza": 7,
}

const cores_map_reverse = {
	0: "vermelho",
	1: "amarelo",
	2: "azul",
	3: "roxo",
	4: "laranja",
	5: "preto",
	6: "verde",
	7: "cinza"
}

# export a dropdown to select the color of the trail
@export var cor_trilha: String = "vermelho":
	set(value):
		cor_trilha = value
		if Engine.is_editor_hint(): return
		if is_node_ready():
			_update_vagoes_cor()

@export var capturado: bool = false:
	set(value):
		capturado = value
		if Engine.is_editor_hint(): return
		if is_node_ready():
			_update_vagoes_saturacao()

var vagoes_array: Array[Vagao] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Vagao:
			vagoes_array.append(child)
	
	_update_vagoes_cor()
	_update_vagoes_saturacao()
func get_qtd_vagoes() -> int:
	# Returns the number of Vagao nodes in the array
	return vagoes_array.size()


func capturar_trilha() -> void:
	if not capturado:
		capturado = true
		_update_vagoes_cor()
		_update_vagoes_saturacao()
		

func highlight_all_vagoes() -> void:
	for vagao_node in vagoes_array:
		if vagao_node and vagao_node.has_method("highlight"):
			vagao_node.highlight()
			
func unhighlight_all_vagoes() -> void:
	for vagao_node in vagoes_array:
		if vagao_node and vagao_node.has_method("unhighlight"):
			vagao_node.unhighlight()

func _update_vagoes_cor() -> void:
	if cores_map.has(cor_trilha):
		var frame_index = cores_map[cor_trilha]
		for vagao_node in vagoes_array:
			# Assuming Vagao has a 'sprite' property which is a Sprite2D
			# and that sprite is named Sprite2D in the Vagao scene.
			if vagao_node and vagao_node.sprite: 
				vagao_node.sprite.frame = frame_index

func _update_vagoes_saturacao() -> void:
	for vagao_node in vagoes_array:
		if vagao_node and vagao_node.has_method("update_saturation"):
			vagao_node.update_saturation(capturado)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
