class_name GerenciadorCartasJogador extends CanvasLayer

var minhas_cartas: Array[GameCard] = []
var isHoveringCard: bool = false
var cardBeingDragged
const LARGURA_CARTA: float = 125*0.85
const QTD_CARTAS: int = 8
const COLLISION_MASK = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	var centro_tela_x = get_viewport().size.x / 2
	
	for i in range(QTD_CARTAS):
		var carta = carta_scene.instantiate()
		adicionarCartaNaMao(carta);
		carta.position = Vector2(centro_tela_x, -500)
		carta.card_index = randi_range(0, 7)
		$".".add_child(carta)

func adicionarCartaNaMao(cartaParaAdicionar: GameCard):
	if cartaParaAdicionar not in minhas_cartas and cartaParaAdicionar != null:
		minhas_cartas.append(cartaParaAdicionar)
	calcularPosicaoDasCartas()

func removerCartaDaMao(cartaParaRemover: GameCard):
	if cartaParaRemover in minhas_cartas:
		minhas_cartas.erase(cartaParaRemover)
		calcularPosicaoDasCartas()
			
func calcularPosicaoDasCartas():
	var centro_tela_x = get_viewport().size.x / 2
	var area_mao_y = get_viewport().size.y - 50
	
	for i in range(minhas_cartas.size()):
		var cartaParaAtualizar = minhas_cartas[i]
		
		var larguraTotalDasCartas = (minhas_cartas.size()-1)*LARGURA_CARTA
		var x_novo_da_carta = centro_tela_x + i*LARGURA_CARTA - larguraTotalDasCartas/2;
		var rotacao_graus = -1.2*(i+1)
		var nova_posicao = Vector2(x_novo_da_carta, area_mao_y + randi_range(0, 25))
		
		cartaParaAtualizar.rotation = deg_to_rad(rotacao_graus)
		cartaParaAtualizar.posicaoInicial = nova_posicao
		var tween = get_tree().create_tween()
		tween.tween_property(cartaParaAtualizar, "position", nova_posicao, 0.4)



# Sistema de Movimentação da Carta

func connect_card_signals(card):
	card.connect("hovered", hovered_on_card)
	card.connect("hoveredOff", hovered_off_card)
	
func hovered_on_card(carta: GameCard):
	if !isHoveringCard:
		isHoveringCard = true
		highlight_card(carta, true)
		
func hovered_off_card(carta: GameCard):
	if !cardBeingDragged:
		highlight_card(carta,false)
		var newCardHovered = raycast_check(COLLISION_MASK)
		if newCardHovered:
			highlight_card(newCardHovered, true)
		else:
			isHoveringCard = false
		
func highlight_card(card, hovered):
	if minhas_cartas.has(card):
		if hovered:
			var tween = get_tree().create_tween()
			tween.tween_property(card, "scale", Vector2(1, 1), 0.05)
			card.z_index = 100
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(card, "scale", Vector2(0.85, 0.8), 0.05)
			card.z_index = 1
			

func start_drag(carta):
	cardBeingDragged = carta
	carta.scale = Vector2(1, 1)			
func stop_drag():
	if (cardBeingDragged != null):
		cardBeingDragged.scale = Vector2(1.05, 1.05)
		cardBeingDragged = null
		adicionarCartaNaMao(cardBeingDragged)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var carta = raycast_check(COLLISION_MASK)
			print(carta)
			if carta:
				start_drag(carta)
		else:
			if cardBeingDragged:
				stop_drag()
				
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_ind = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var curr_card = cards[i].collider.get_parent()
		if curr_card.z_index > highest_z_ind:
			highest_z_card = curr_card
			highest_z_ind = highest_z_card.z_index
	
	return highest_z_card

func raycast_check(_collider: int): # collider parameter is no longer used
	var cards_under_mouse: Array[GameCard] = []
	var mouse_pos = get_viewport().get_mouse_position()

	for card in minhas_cartas:
		if is_instance_valid(card) and is_instance_valid(card.get_node_or_null("Area2D/CollisionShape2D")):
			var collision_shape = card.get_node("Area2D/CollisionShape2D") as CollisionShape2D
			if not is_instance_valid(collision_shape.shape):
				continue

			# Get the extents of the collision shape
			var shape_extents = collision_shape.shape.get_rect().size / 2.0
			
			# Calculate the global scale of the card
			var card_global_scale = card.get_global_transform().get_scale()

			# Apply scale to the shape extents
			var scaled_extents = shape_extents * card_global_scale

			# Calculate the card's bounding box in global coordinates
			# The card's global_position is its center if it's a Node2D.
			# If the CollisionShape2D is offset from the GameCard's origin, that needs to be accounted for.
			# Assuming CollisionShape2D is centered or its position is relative to GameCard origin.
			var card_global_center = card.global_position + collision_shape.global_position - card.global_position # Offset of collision shape
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

func _process(delta: float) -> void:
	if cardBeingDragged:
		var mouse_pos = get_viewport().get_mouse_position()
		cardBeingDragged.position = mouse_pos
