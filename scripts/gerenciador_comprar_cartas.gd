class_name GerenciadorComprarCartas extends Node


const max_num_cartas_loja = 5
var cartas_da_loja: Array[GameCard] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instanciarCartasLoja()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var carta = raycast_check()
			if carta:
				print("Clicando em carta, removendo da loja e adicionando no inventário")
				cartas_da_loja.erase(carta)
				carta.desconectarDetectoresDeMovimento()
				$"../LojaCartasContainer".remove_child(carta)
				$"../../GerenciadorCartasJogador".add_child(carta)
				$"../../GerenciadorCartasJogador".adicionarCartaNaMao(carta)
				carta.conectarDetectoresDeMovimento()
				calcularPosicaoDasCartas()


func adicionarCartaAleatoriaNaLoja(inFor: bool = false) -> void:
		var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
		var carta = carta_scene.instantiate()
		var cor_aleatoria = randi_range(0,7)
		carta.card_index = cor_aleatoria
		carta.rotation_degrees = 90
		carta.scale = Vector2(0.5, 0.5)
		var viewport_width = get_viewport().size.x
		var viewport_height = get_viewport().size.y
		carta.position = Vector2(viewport_width-35, viewport_height)
		cartas_da_loja.append(carta)
		$"../LojaCartasContainer".add_child(carta)
		if (!inFor):
			calcularPosicaoDasCartas()


func instanciarCartasLoja() -> void:
	for i in range(max_num_cartas_loja-len(cartas_da_loja)):
		adicionarCartaAleatoriaNaLoja(true)
	calcularPosicaoDasCartas()
	
func calcularPosicaoDasCartas():
	if not cartas_da_loja: return
	var centro_tela_x = get_viewport().size.x / 2
	var area_mao_y = get_viewport().size.y - 50
	
	for i in range(cartas_da_loja.size()):
		var cartaParaAtualizar = cartas_da_loja[i]
		
		var viewport_width = get_viewport().size.x
		var nova_posicao =Vector2(viewport_width-35, i*82+100)
		
		var tween = get_tree().create_tween().set_parallel(true)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(cartaParaAtualizar, "position", nova_posicao, 0.4)
		tween.tween_property(cartaParaAtualizar, "rotation_degrees", 90, 0.4)
		tween.tween_property(cartaParaAtualizar, "scale", Vector2(0.5,0.5), 0.4)

func raycast_check() -> GameCard: 
	
	var cards_under_mouse: Array[GameCard] = []
	var mouse_pos = get_viewport().get_mouse_position()

	for card in cartas_da_loja:
		if is_instance_valid(card) and is_instance_valid(card.get_node_or_null("Area2D/CollisionShape2D")):
			var collision_shape = card.get_node("Area2D/CollisionShape2D") as CollisionShape2D
			if not is_instance_valid(collision_shape.shape):
				continue

			var shape_extents = collision_shape.shape.get_rect().size / 2.0
			
			var card_global_scale = card.get_global_transform().get_scale()

			var scaled_extents = shape_extents * card_global_scale

			var card_global_center = card.global_position + collision_shape.global_position - card.global_position 
			var top_left = card_global_center - scaled_extents
			var bottom_right = card_global_center + scaled_extents
			
			var global_card_rect = Rect2(top_left, bottom_right - top_left)

			if global_card_rect.has_point(mouse_pos):
				cards_under_mouse.append(card)
	
	if cards_under_mouse.size() > 0:
		if cards_under_mouse.size() == 1:
			return cards_under_mouse[0]
		else:
			var highest_z_card = cards_under_mouse[0]
			for i in range(1, cards_under_mouse.size()):
				if cards_under_mouse[i].z_index > highest_z_card.z_index:
					highest_z_card = cards_under_mouse[i]
			return highest_z_card
	return null
