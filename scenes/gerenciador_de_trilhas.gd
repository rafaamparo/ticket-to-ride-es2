class_name GerenciadorDeTrilhas extends Node2D

var lista_trilhas: Array[TrilhaVagao] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for trilha_node in get_children():
		if trilha_node is TrilhaVagao:
			var trilha = trilha_node as TrilhaVagao
			if is_instance_valid(trilha):
				lista_trilhas.append(trilha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: # Added underscore to delta
	pass

func unhighlight_all_trilhas() -> void:
	for trilha_node in get_children():
		if trilha_node is TrilhaVagao:
			var trilha = trilha_node as TrilhaVagao
			if is_instance_valid(trilha):
				trilha.unhighlight_all_vagoes()

func get_trilha_sob_retangulo(p_screen_rect: Rect2) -> TrilhaVagao:
	for trilha_node in get_children():
		if trilha_node is TrilhaVagao:
			var trilha = trilha_node as TrilhaVagao
			if not is_instance_valid(trilha):
				continue

			for vagao in trilha.vagoes_array:
				if is_instance_valid(vagao):
					var vagao_sprite = vagao.get_node_or_null("Sprite2D") as Sprite2D
					if is_instance_valid(vagao_sprite) and is_instance_valid(vagao_sprite.texture):
						var sprite_local_rect = vagao_sprite.get_rect()
						var sprite_top_left_local = sprite_local_rect.position
						var sprite_bottom_right_local = sprite_local_rect.end
						
						var T_sprite_to_canvas = vagao_sprite.get_global_transform_with_canvas()
						
						var vagao_top_left_screen = T_sprite_to_canvas * sprite_top_left_local
						var vagao_bottom_right_screen = T_sprite_to_canvas * sprite_bottom_right_local
						
						var screen_rect_min_x = min(vagao_top_left_screen.x, vagao_bottom_right_screen.x)
						var screen_rect_min_y = min(vagao_top_left_screen.y, vagao_bottom_right_screen.y)
						var screen_rect_max_x = max(vagao_top_left_screen.x, vagao_bottom_right_screen.x)
						var screen_rect_max_y = max(vagao_top_left_screen.y, vagao_bottom_right_screen.y)
						
						var screen_rect_pos = Vector2(screen_rect_min_x, screen_rect_min_y)
						var screen_rect_size = Vector2(screen_rect_max_x - screen_rect_min_x, screen_rect_max_y - screen_rect_min_y)
						var vagao_sprite_screen_rect = Rect2(screen_rect_pos, screen_rect_size)

						if p_screen_rect.intersects(vagao_sprite_screen_rect):
							return trilha # Found intersecting trilha
	return null # No intersection found


func animacaoCapturaTrilha(trilha_selecionada: TrilhaVagao, cartas_de_captura: Array[GameCard]):
	var camera = $"../Camera2D"
	var gerenciadorDeFluxoRef = $"../GerenciadorDeFluxoJogo"

	if !trilha_selecionada or trilha_selecionada.vagoes_array.is_empty():
		return;
	
	var vagoes = trilha_selecionada.vagoes_array
	var middle_vagao = vagoes[int(vagoes.size() / 2)]
		
	if camera and camera.has_method("tween_to"):
		# This value is from player_camera.gd. It's not ideal to have it here,
		# but it's needed to correctly calculate the camera's target position.
		var system_offset := Vector2(576.0, 324.0)
		var correction = -system_offset / camera.zoom.x
		var target_position = middle_vagao.global_position + correction
		
		# The last parameter is the zoom level. 1.5 means 1.5x zoom.
		await camera.tween_to(target_position, 1.0)

		var cena_carta = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
		var carta_instance = cena_carta.instantiate()
		carta_instance.card_index = 7
		carta_instance.position =  Vector2(middle_vagao.global_position[0] - 450, 200) # Adjust position above the middle vagao
		carta_instance.scale = Vector2(0.9, 0.9) # Adjust scale for visibility
		carta_instance.z_index = 1000 # Ensure it appears above

		# Add the card instance to the scene tree
		gerenciadorDeFluxoRef.add_child(carta_instance)

		# animate the card going to the middle vagao, then, after the animation, reduce the card size to 0 and remove it
		var tween = carta_instance.create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_parallel(true)
		tween.tween_property(carta_instance, "position", middle_vagao.global_position + Vector2(0, -20), 0.5)
		tween.tween_property(carta_instance, "scale", Vector2(0, 0), 0.75).finished.connect(func():
			carta_instance.queue_free())
		await tween.finished
