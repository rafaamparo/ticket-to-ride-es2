class_name GerenciadorDeParadas extends Control


var lista_paradas: Array[Parada] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for parada_node in get_children():
		if parada_node is Parada:
			var parada = parada_node as Parada
			if is_instance_valid(parada):
				lista_paradas.append(parada)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
