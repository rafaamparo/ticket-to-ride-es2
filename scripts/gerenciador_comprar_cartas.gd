class_name GerenciadorComprarCartas extends Node


const max_num_cartas_loja = 5
const max_cartas_para_comprar = 2
var gerenciadorFluxoDeJogo: GerenciadorDeFluxo = null
var cartas_da_loja: Array[GameCard] = []
var cartas_compradas_turno_loja: Array[GameCard] = []
var cartas_compradas_turno_baralho: Array[GameCard] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerenciadorFluxoDeJogo = $"../../GerenciadorDeFluxoJogo";
	atualizarTurnoLoja()
	instanciarCartasLoja()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if verificarSeJogadorFinalizouAcao():
		print("Jogador finalizou a ação de compra de cartas")
		gerenciadorFluxoDeJogo.acao_jogador_terminada.emit()
		return
		
	if gerenciadorFluxoDeJogo.pausar_jogador_principal == false and cartas_compradas_turno_baralho.size() + cartas_compradas_turno_loja.size() >= 1:
		gerenciadorFluxoDeJogo.pausar_cartas_mao_jogador_princial = true;
	elif gerenciadorFluxoDeJogo.pausar_jogador_principal == false:
		gerenciadorFluxoDeJogo.pausar_cartas_mao_jogador_princial = false;

	for carta in cartas_da_loja:
		if not verificarSePodeComprarCarta(carta, false) or gerenciadorFluxoDeJogo.pausar_jogador_principal:
			# deixe a carta escura
			carta.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			# deixe a carta normal
			carta.modulate = Color(1, 1, 1, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var carta = raycast_check()
			if carta and verificarSePodeComprarCarta(carta) and not gerenciadorFluxoDeJogo.pausar_jogador_principal:
				print("Clicando em carta, removendo da loja e adicionando no inventário")
				cartas_da_loja.erase(carta)
				carta.desconectarDetectoresDeMovimento()
				$"../LojaCartasContainer".remove_child(carta)
				$"../../GerenciadorCartasJogador".add_child(carta)
				$"../../GerenciadorCartasJogador".adicionarCartaNaMao(carta)
				cartas_compradas_turno_loja.append(carta)
				carta.conectarDetectoresDeMovimento()
				await calcularPosicaoDasCartas()
				instanciarCartasLoja()

func comprarCartaDaLoja(jogadorSelecionado: Jogador, cartaSelecionada: GameCard) -> void:
	if cartas_da_loja.size() == 0:
		print("Não há cartas na loja para comprar")
		return

	if not is_instance_valid(cartaSelecionada):
		print("Carta selecionada não é válida")
		return

	if not is_instance_valid(jogadorSelecionado):
		print("Jogador selecionado não é válido")
		return

	if cartas_da_loja.has(cartaSelecionada):
		print("Removendo carta da loja e adicionando no inventário do jogador")
		cartas_da_loja.erase(cartaSelecionada)
		cartaSelecionada.desconectarDetectoresDeMovimento()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		var target_position = jogadorSelecionado.player_info_box.position + Vector2(-100, 50)
		tween.tween_property(cartaSelecionada, "position", target_position, 0.4)
		await tween.finished
		$"../LojaCartasContainer".remove_child(cartaSelecionada)
		jogadorSelecionado.adicionarCartaNaMao(cartaSelecionada)
		cartas_compradas_turno_loja.append(cartaSelecionada)
		await calcularPosicaoDasCartas()
		instanciarCartasLoja()
	else:
		print("Carta selecionada não está na loja")
	

func comprarCartaDoBaralho(jogadorSelecionado: Jogador, cartaGerada: GameCard = null) -> void:
	if not verificarSePodePegarDoBaralho():
		print("Não pode comprar mais cartas do baralho neste turno")
		return
	
	var carta = null
	if (!cartaGerada):
		var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
		carta = carta_scene.instantiate()
		var cor_aleatoria = randi_range(0,7)
		carta.card_index = cor_aleatoria
		jogadorSelecionado.adicionarCartaNaMao(carta)
		cartas_compradas_turno_baralho.append(carta)
	else:
		cartas_compradas_turno_baralho.append(cartaGerada)
		carta = cartaGerada
	

	if jogadorSelecionado.isBot:
		carta.scale = Vector2(0.35, 0.35)
		var viewport_width = get_viewport().size.x
		carta.position = Vector2(viewport_width,30)
		$"../LojaCartasContainer".add_child(carta)
		carta.desconectarDetectoresDeMovimento()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)

		var target_position = jogadorSelecionado.player_info_box.position + Vector2(-100, 55)
		tween.tween_property(carta, "position", target_position, 0.4)
		await tween.finished
		$"../LojaCartasContainer".remove_child(carta)
		




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
	
	var tweens_list = []
	for i in range(cartas_da_loja.size()):
		var cartaParaAtualizar = cartas_da_loja[i]
		
		var viewport_width = get_viewport().size.x
		var nova_posicao =Vector2(viewport_width-35, i*82+125)
		
		var tween = get_tree().create_tween().set_parallel(true)
		tweens_list.append(tween)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(cartaParaAtualizar, "position", nova_posicao, 0.4)
		tween.tween_property(cartaParaAtualizar, "rotation_degrees", 90, 0.4)
		tween.tween_property(cartaParaAtualizar, "scale", Vector2(0.5,0.5), 0.4)
	
	for tween in tweens_list:
		await tween.finished
	# After all tweens are finished, we can safely return
	return


func atualizarTurnoLoja() -> void:
	cartas_compradas_turno_loja.clear()
	cartas_compradas_turno_baralho.clear()

func verificarSePodeComprarCarta(carta: GameCard, logs = true) -> bool:
	if not is_instance_valid(carta):
		return false
	
	if (cartas_compradas_turno_loja.size() + cartas_compradas_turno_baralho.size()) >= max_cartas_para_comprar:
		if logs: print("Já comprou o máximo de cartas da loja neste turno")
		return false
	
	# Se carta.card_index == 7 e a soma de (cartas_compradas_turno_loja.size() + cartas_compradas_turno_baralho.size()) >= 1, não pode comprar
	if carta.card_index == 7 and (cartas_compradas_turno_loja.size() + cartas_compradas_turno_baralho.size()) >= 1:
		if logs: print("Não é possível comprar mais de uma carta de coringa por turno")
		return false
	
	# Se o jogador já comprou uma carta de coringa neste turno, não pode comprar outra
	var cartas_coringa_no_baralho_loja = cartas_compradas_turno_loja.filter(func(carta_do_baralho):

		if not is_instance_valid(carta_do_baralho):
			return false

		return carta_do_baralho.card_index == 7
	)

	if cartas_coringa_no_baralho_loja.size() > 0:
		if logs: print("Já comprou uma carta de coringa neste turno")
		return false

	return true

func verificarSeJogadorFinalizouAcao() -> bool:
	if gerenciadorFluxoDeJogo.pausar_jogador_principal == true:
		return false

	if cartas_compradas_turno_loja.size() + cartas_compradas_turno_baralho.size() >= max_cartas_para_comprar:
		return true

	var cartas_coringa_no_baralho_loja = cartas_compradas_turno_loja.filter(func(carta_do_baralho):

		if not is_instance_valid(carta_do_baralho):
			return false

		return carta_do_baralho.card_index == 7
	)

	if cartas_coringa_no_baralho_loja.size() > 0:
		return true
	
	return false

func verificarSePodePegarDoBaralho() -> bool:
	if (cartas_compradas_turno_baralho.size() + cartas_compradas_turno_loja.size()) >= max_cartas_para_comprar:
		print("Já comprou o máximo de cartas do baralho neste turno")
		return false
	
	# Se o jogador já comprou uma carta de coringa neste turno, não pode comprar outra
	var cartas_coringa_no_baralho_loja = cartas_compradas_turno_loja.filter(func(carta_do_baralho):

		if not is_instance_valid(carta_do_baralho):
			return false

		return carta_do_baralho.card_index == 7
	)

	if cartas_coringa_no_baralho_loja.size() > 0:
		print("Já comprou uma carta de coringa neste turno")
		return false

	return true

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
