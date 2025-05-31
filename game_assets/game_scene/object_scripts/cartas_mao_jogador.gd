class_name GerenciadorCartasJogador extends CanvasLayer

var minhas_cartas: Array[GameCard] = []
var isHoveringCard: bool = false
var cardBeingDragged: GameCard = null
var gerenciadorDeTrilhosRef: GerenciadorDeTrilhas = null
const LARGURA_CARTA: float = 125*0.85
const QTD_CARTAS: int = 8
const COLLISION_MASK = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	var centro_tela_x = get_viewport().size.x / 2
	gerenciadorDeTrilhosRef = $"../GerenciadorDeTrilhas"
	
	for i in range(QTD_CARTAS):
		var carta = carta_scene.instantiate()
		adicionarCartaNaMao(carta);
		carta.position = Vector2(centro_tela_x, -500)
		carta.card_index = randi_range(0, 7)
		carta.z_index = i
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
			var tween1 = get_tree().create_tween().set_parallel(true)
			tween1.tween_property(card, "scale", Vector2(0.9, 0.9), 0.05)
			await tween1.finished
			card.scale =  Vector2(0.9, 0.9)
			card.z_index = 100
		else:
			var tween2 = get_tree().create_tween().set_parallel(true)
			tween2.tween_property(card, "scale", Vector2(0.85, 0.85), 0.05)
			card.z_index = 1
			

func get_card_global_rect(card_node: GameCard) -> Rect2:
	# Attempt to get bounds from CollisionShape2D within an Area2D child
	var collision_shape = card_node.get_node_or_null("Area2D/CollisionShape2D") as CollisionShape2D
	if is_instance_valid(collision_shape) and is_instance_valid(collision_shape.shape):
		var shape_local_rect: Rect2 = collision_shape.shape.get_rect()
		# The collision_shape's global_transform correctly positions and scales this local_rect.
		return collision_shape.get_global_transform() * shape_local_rect
	
	# Fallback if the expected collision shape isn't found
	printerr("Could not find valid CollisionShape2D for card: ", card_node.name, " at path Area2D/CollisionShape2D")
	
	# Last resort: return an empty rect at the card's global position
	return Rect2(card_node.global_position, Vector2.ZERO)

func start_drag(carta):
	cardBeingDragged = carta
	# Consider removing the card from 'minhas_cartas' here if it shouldn't be interactable while dragging
	# e.g., removerCartaDaMao(carta) 
	# For now, keeping original behavior where it's still in the list.
	carta.scale = Vector2(0.65, 0.65)

func stop_drag():
	if cardBeingDragged != null:
		var actual_card_being_dragged: GameCard = cardBeingDragged
		var card_rect: Rect2 = get_card_global_rect(actual_card_being_dragged)
		
		var trilha_detectada: TrilhaVagao = null

		if gerenciadorDeTrilhosRef != null and card_rect.size != Vector2.ZERO: 
			trilha_detectada = gerenciadorDeTrilhosRef.get_trilha_sob_retangulo(card_rect)
			if trilha_detectada:
				print("Carta '", actual_card_being_dragged.name, "' sobre a trilha: ", trilha_detectada.name)
		
		actual_card_being_dragged.scale = Vector2(0.85, 0.85)
		cardBeingDragged = null # Clear the reference to the card being dragged

		# If a track was detected, you might want to handle the card differently
		# (e.g., remove it from hand, associate it with the track).
		# For now, as per prompt, just printing and then adding back to hand.
		if trilha_detectada:
			print("Card '", actual_card_being_dragged.name, "' should be played on the track: ", trilha_detectada.name)
			# Example: If card should be "played" on the track:
			# removerCartaDaMao(actual_card_being_dragged)
			# actual_card_being_dragged.queue_free() # or some other logic
			# For now, it will be added back to hand below.
			pass

		adicionarCartaNaMao(actual_card_being_dragged) # Add the card back to hand (fixed bug here)

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

func _process(_delta: float) -> void: # Added underscore to delta
	if cardBeingDragged:
		var mouse_pos = get_viewport().get_mouse_position()
		cardBeingDragged.position = mouse_pos
		
		# Check if the dragged card is over a trilha
		var card_rect: Rect2 = get_card_global_rect(cardBeingDragged)
		if gerenciadorDeTrilhosRef != null and card_rect.size != Vector2.ZERO:
			var trilha_sob_carta: TrilhaVagao = gerenciadorDeTrilhosRef.get_trilha_sob_retangulo(card_rect)
			if trilha_sob_carta:
				print("Card '", cardBeingDragged.name, "' is currently hovering over trilha: ", trilha_sob_carta.name)
			# else:
				# Optional: print something if it's not over any track, or handle highlighting removal here
				# print("Card is not over any trilha")
