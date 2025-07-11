class_name GerenciadorCartasJogador extends CanvasLayer

var gerenciadorDeFluxoDeJogo: GerenciadorDeFluxo = null
var jogador_principal: Jogador
var isHoveringCard: bool = false
var cardBeingDragged: GameCard = null
var gerenciadorDeTrilhosRef: GerenciadorDeTrilhas = null
var escala_dinamica: float = 0.85
var escala_highlight_dinamica: float = escala_dinamica+0.1
var LARGURA_CARTA: float = 125*escala_dinamica
const QTD_CARTAS: int = 6
const COLLISION_MASK = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerenciadorDeFluxoDeJogo = $"../GerenciadorDeFluxoJogo";
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	var centro_tela_x = get_viewport().size.x / 2
	gerenciadorDeTrilhosRef = $"../GerenciadorDeTrilhas"
	
	# A inicialização das cartas agora depende do jogador_principal ser definido
	# Vamos esperar que o gerenciador de fluxo de jogo o configure.

func inicializar_cartas_jogador():
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	var centro_tela_x = get_viewport().size.x / 2
	for i in range(Globals.qtd_cartas_inicio):
		var carta = carta_scene.instantiate()
		var cor_aleatoria = randi_range(0,7)
		if cor_aleatoria == 7 and jogador_principal.cartas_coringa >= 2:
			cor_aleatoria = randi_range(0,6)
		
		carta.card_index = cor_aleatoria
		adicionarCartaNaMao(carta);
		carta.position = Vector2(centro_tela_x, -500)
		var rotacao_graus = -1.2*(i+1)
		carta.rotation = deg_to_rad(rotacao_graus)
		carta.z_index = i
		$".".add_child(carta)
		
func gerarCartaAleatoria() -> GameCard:
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	var centro_tela_x = get_viewport().size.x / 2
	var carta = carta_scene.instantiate()
	var cor_aleatoria = randi_range(0,7)
	
	carta.card_index = cor_aleatoria
	adicionarCartaNaMao(carta)
	
	carta.position = Vector2(centro_tela_x, -500)
	var rotacao_graus = 0
	carta.rotation = deg_to_rad(rotacao_graus)
	carta.z_index = jogador_principal.cartas.size()
	$".".add_child(carta)
	return carta

func adicionarCartaNaMao(cartaParaAdicionar: GameCard):
	if jogador_principal and cartaParaAdicionar != null:
		jogador_principal.adicionarCartaNaMao(cartaParaAdicionar)
		calcularPosicaoDasCartas()

func removerCartaDaMao(cartaParaRemover: GameCard, should_call_calculate: bool = true):
	if jogador_principal and cartaParaRemover in jogador_principal.cartas:
		jogador_principal.removerCartaDaMao(cartaParaRemover)
		if should_call_calculate:
			calcularPosicaoDasCartas()
			
func calcularPosicaoDasCartas():
	if not jogador_principal: return
	var centro_tela_x = get_viewport().size.x / 2
	await ajustarEscalaDasCartasDinamicamente()
	var area_mao_y = get_viewport().size.y - 50 + (1-escala_dinamica)*14
	
	for i in range(jogador_principal.cartas.size()):
		var cartaParaAtualizar = jogador_principal.cartas[i]
		
		var larguraTotalDasCartas = (jogador_principal.cartas.size()-1)*LARGURA_CARTA
		var x_novo_da_carta = centro_tela_x + i*LARGURA_CARTA - larguraTotalDasCartas/2;
		var rotacao_graus = -1.2*((i%4)+1)
		var nova_posicao = Vector2(x_novo_da_carta, area_mao_y + jogador_principal.cartas[i].y_offset)
		
		cartaParaAtualizar.previous_rotation = deg_to_rad(rotacao_graus)
		cartaParaAtualizar.posicaoInicial = nova_posicao
		var tween = get_tree().create_tween().set_parallel(true)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(cartaParaAtualizar, "position", nova_posicao, 0.4)
		tween.tween_property(cartaParaAtualizar, "rotation", deg_to_rad(rotacao_graus), 0.4)
		tween.tween_property(cartaParaAtualizar, "scale", Vector2(escala_dinamica,escala_dinamica), 0.4)

# Sistema de Movimentação da Carta
func connect_card_signals(card):
	card.connect("hovered", hovered_on_card)
	card.connect("hoveredOff", hovered_off_card)

func disconnect_card_signals(card):
	card.disconnect("hovered", hovered_on_card)
	card.disconnect("hoveredOff", hovered_off_card)
	
func hovered_on_card(carta: GameCard):
	if gerenciadorDeFluxoDeJogo.pausar_jogador_principal or gerenciadorDeFluxoDeJogo.pausar_cartas_mao_jogador_princial:
		return;
	if !isHoveringCard:
		isHoveringCard = true
		highlight_card(carta, true)
		
func hovered_off_card(carta: GameCard):
	if !cardBeingDragged:
		highlight_card(carta,false)
		var newCardHovered = raycast_check(COLLISION_MASK)
		if newCardHovered and !gerenciadorDeFluxoDeJogo.pausar_jogador_principal and !gerenciadorDeFluxoDeJogo.pausar_cartas_mao_jogador_princial:
			highlight_card(newCardHovered, true)
		else:
			isHoveringCard = false
		
func highlight_card(card, hovered):
	if jogador_principal and jogador_principal.cartas.has(card):
		if hovered:
			var tween1 = get_tree().create_tween().set_parallel(true)
			tween1.tween_property(card, "scale", Vector2(escala_highlight_dinamica, escala_highlight_dinamica), 0.05)
			await tween1.finished
			card.scale =  Vector2(escala_highlight_dinamica, escala_highlight_dinamica)
			card.z_index = 100
		else:
			var tween2 = get_tree().create_tween().set_parallel(true)
			tween2.tween_property(card, "scale", Vector2(escala_dinamica, escala_dinamica), 0.05)
			card.z_index = 1
			

func get_card_global_rect(card_node: GameCard) -> Rect2:
	var collision_shape = card_node.get_node_or_null("Area2D/CollisionShape2D") as CollisionShape2D
	if is_instance_valid(collision_shape) and is_instance_valid(collision_shape.shape):
		var shape_local_rect: Rect2 = collision_shape.shape.get_rect()
		return collision_shape.get_global_transform() * shape_local_rect
	return Rect2(card_node.global_position, Vector2.ZERO)

func start_drag(carta):
	if gerenciadorDeFluxoDeJogo.pausar_jogador_principal or gerenciadorDeFluxoDeJogo.pausar_cartas_mao_jogador_princial:
		return;
	cardBeingDragged = carta
	var tween = get_tree().create_tween()
	tween.tween_property(carta, "scale", Vector2(0.5, 0.5), 0.1).set_ease(Tween.EASE_OUT)

func stop_drag():
	if cardBeingDragged != null:
		var actual_card_being_dragged: GameCard = cardBeingDragged
		var card_rect: Rect2 = get_card_global_rect(actual_card_being_dragged)
		
		var trilha_detectada: TrilhaVagao = null

		if gerenciadorDeTrilhosRef != null and card_rect.size != Vector2.ZERO: 
			trilha_detectada = gerenciadorDeTrilhosRef.get_trilha_sob_retangulo(card_rect)
			if trilha_detectada:
				
				# Esteremos obtemos todas as cartas de mesma cor juntamente com as cartas coringa
				print("Carta '", actual_card_being_dragged.name, "' sobre a trilha: ", trilha_detectada.name)
				var cartas_mesma_cor = jogador_principal.obterCartasMesmaCor(actual_card_being_dragged.card_index, true)
				
				if trilha_detectada.capturado:
					print("Trilha já capturada, não pode jogar a carta.")
				elif actual_card_being_dragged.card_index != 7 && trilha_detectada.cores_map[trilha_detectada.cor_trilha] != 7 && trilha_detectada.cores_map[trilha_detectada.cor_trilha] != actual_card_being_dragged.card_index:
					print("Carta de cor errada para esta trilha.")
				elif trilha_detectada.get_qtd_vagoes() > cartas_mesma_cor.size():
					print("Número de vagões na trilha é maior do que o número de cartas na mão.")
				else:
					print("Carta jogada na trilha com sucesso!")
					gerenciadorDeFluxoDeJogo.acao_jogador_terminada.emit()
					actual_card_being_dragged.isBeingAdded = true
					var freeze_position = actual_card_being_dragged.position
					var num_vagoes_necessarios = trilha_detectada.get_qtd_vagoes()
					
					var cartas_a_serem_usadas: Array[GameCard] = []
					if actual_card_being_dragged in cartas_mesma_cor:
						cartas_a_serem_usadas.append(actual_card_being_dragged)

					var idx = 0
					while cartas_a_serem_usadas.size() < num_vagoes_necessarios and idx < cartas_mesma_cor.size():
						var carta_candidata = cartas_mesma_cor[idx]
						if not cartas_a_serem_usadas.has(carta_candidata):
							cartas_a_serem_usadas.append(carta_candidata)
						idx += 1
					
					var gather_animation_tween = get_tree().create_tween().set_parallel()
					var animation_added = false

					
					for carta_to_animate in cartas_a_serem_usadas:
						if carta_to_animate == actual_card_being_dragged:
							continue 

						if not is_instance_valid(carta_to_animate):
							continue

						animation_added = true
						
						var random_offset = Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
						var target_position = freeze_position + random_offset
						
						gather_animation_tween.tween_property(carta_to_animate, "position", target_position, 0.37).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
						gather_animation_tween.tween_property(carta_to_animate, "scale", Vector2(0,0), 0.37).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
						
						if is_instance_valid(actual_card_being_dragged):
							carta_to_animate.z_index = actual_card_being_dragged.z_index - 1
						else:
							carta_to_animate.z_index = 90 
					gather_animation_tween.tween_property(actual_card_being_dragged, "scale", Vector2(0,0), 0.37).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					animation_added = true

					if animation_added:
						await gather_animation_tween.finished

					for carta_usada in cartas_a_serem_usadas:
						# carta_usada.scale = Vector2(0.5, 0.5) 
						removerCartaDaMao(carta_usada, false)
						if is_instance_valid(carta_usada):
							carta_usada.queue_free() 
					
					# print(jogador_principal.cartas)
					if trilha_detectada.cores_map[trilha_detectada.cor_trilha] == 7:
						trilha_detectada.cor_trilha = trilha_detectada.cores_map_reverse[actual_card_being_dragged.card_index]
					trilha_detectada.capturar_trilha(self.jogador_principal) 
					jogador_principal.caminhosCapturados.append(trilha_detectada)
					jogador_principal.pontos += trilha_detectada.pontos_da_trilha
					jogador_principal.trens -= num_vagoes_necessarios
			
					cardBeingDragged = null
					gerenciadorDeTrilhosRef.unhighlight_all_trilhas() 
					await unhighlight_deck_cards()
					calcularPosicaoDasCartas()
					gerenciadorDeFluxoDeJogo.acao_jogador_terminada.emit()

					return

		actual_card_being_dragged.scale = Vector2(0.7, 0.7)
		cardBeingDragged = null 

		gerenciadorDeTrilhosRef.unhighlight_all_trilhas()
		adicionarCartaNaMao(actual_card_being_dragged) #

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var carta = raycast_check(COLLISION_MASK)
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

func highlight_deck_cards(color_index: int):
	if not jogador_principal: return
	for card in jogador_principal.cartas:
		if is_instance_valid(card):

			if card == cardBeingDragged:
				continue

			# print("Highlighting card: ", card.name, " with index: ", card.card_index)
			if card.card_index != 7 and card.card_index != color_index:
				continue

			if card.is_focused:
				continue
			
			card.is_focused = true
			card.previous_rotation = card.rotation
			card.previous_position = card.position

			var tween = get_tree().create_tween()
			tween.tween_property(card, "rotation", 0, 0.2)
			var max_y_position = get_viewport().size.y - 100

			tween.tween_property(card, "position", Vector2(card.position.x, max(card.position.y - 50, max_y_position)), 0.2)
			tween.set_ease(Tween.EASE_IN_OUT)


func unhighlight_deck_cards():
	if not jogador_principal: return
	for card in jogador_principal.cartas:
		if is_instance_valid(card):
			card.is_focused = false
			if card.previous_rotation != null:
				if card == cardBeingDragged:
					continue

				var rotation_to_restore = card.previous_rotation if card.previous_rotation != null else 0
				var position_to_restore = card.previous_position if card.previous_position != null else card.position

				card.previous_rotation = null
				card.previous_position = null
				var tween = get_tree().create_tween()
				tween.tween_property(card, "rotation", rotation_to_restore, 0.2)
				tween.tween_property(card, "position", position_to_restore, 0.2)
				tween.set_ease(Tween.EASE_IN_OUT)
				# await tween.finished

func raycast_check(_collider: int): 
	if not jogador_principal: return null
	var cards_under_mouse: Array[GameCard] = []
	var mouse_pos = get_viewport().get_mouse_position()

	for card in jogador_principal.cartas:
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

func ajustarEscalaDasCartasDinamicamente() -> void:
	if jogador_principal.cartas.size() > 35:
		escala_dinamica = 0.15
	elif jogador_principal.cartas.size() > 30:
		escala_dinamica = 0.25
	elif jogador_principal.cartas.size() > 20:
		escala_dinamica = 0.30
	elif jogador_principal.cartas.size() > 15:
		escala_dinamica = 0.35
	elif jogador_principal.cartas.size() > 10:
		escala_dinamica = 0.50
	elif jogador_principal.cartas.size() > 8:
		escala_dinamica = 0.60
	elif jogador_principal.cartas.size() > 7:
		escala_dinamica = 0.70
	else:	
		escala_dinamica = 0.85
	
	LARGURA_CARTA = 125*escala_dinamica
	escala_highlight_dinamica = escala_dinamica+0.1
	

func _process(_delta: float) -> void: 
	

	
	
	if not jogador_principal: return
	$"../GUI/Jogador Principal/pontos".text = str(jogador_principal.pontos)
	$"../GUI/Jogador Principal/trens".text = str(jogador_principal.trens)
	$"../GUI/Jogador Principal/Nome".text = jogador_principal.nome
	var cartas_destino_completas = jogador_principal.cartas_destino.duplicate(true)
	# filter cartas com completado 
	cartas_destino_completas = cartas_destino_completas.filter(func(carta: CartaDestino) -> bool:
		return carta.concluida
	)
	$"../GUI/Jogador Principal/bilhetes_relacao".text = str(cartas_destino_completas.size()) + "/" + str(jogador_principal.cartas_destino.size())
	if gerenciadorDeFluxoDeJogo.pausar_jogador_principal or gerenciadorDeFluxoDeJogo.pausar_cartas_mao_jogador_princial:
		for carta in jogador_principal.cartas:
			# maake each carta a little bit darker
			if is_instance_valid(carta):
				carta.modulate = Color(0.5, 0.5, 0.5, 1.0)
		return
	else: 
		for carta in jogador_principal.cartas:
			if is_instance_valid(carta):
				carta.modulate = Color(1.0, 1.0, 1.0, 1.0)
			
	
	if cardBeingDragged:
		var mouse_pos = get_viewport().get_mouse_position()
		if not cardBeingDragged.isBeingAdded:
			cardBeingDragged.position = mouse_pos
		var card_rect: Rect2 = get_card_global_rect(cardBeingDragged)
		if gerenciadorDeTrilhosRef != null and card_rect.size != Vector2.ZERO:
			var trilha_sob_carta: TrilhaVagao = gerenciadorDeTrilhosRef.get_trilha_sob_retangulo(card_rect)
			if trilha_sob_carta:
				gerenciadorDeTrilhosRef.unhighlight_all_trilhas()
				# print(cardBeingDragged.card_index == 7 or trilha_sob_carta.cores_map[trilha_sob_carta.cor_trilha] == cardBeingDragged.card_index)
				if (not trilha_sob_carta.capturado and (cardBeingDragged.card_index == 7 or trilha_sob_carta.cores_map[trilha_sob_carta.cor_trilha] == 7 or trilha_sob_carta.cores_map[trilha_sob_carta.cor_trilha] == cardBeingDragged.card_index) ):
					trilha_sob_carta.highlight_all_vagoes()
					highlight_deck_cards(cardBeingDragged.card_index) 
				else:
					unhighlight_deck_cards()
			else:
				gerenciadorDeTrilhosRef.unhighlight_all_trilhas()
				unhighlight_deck_cards()
