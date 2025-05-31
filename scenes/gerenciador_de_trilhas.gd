class_name GerenciadorDeTrilhas extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
