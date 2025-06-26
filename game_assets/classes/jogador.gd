class_name Jogador extends Node2D


var nome: String = "Jogador BOT"
var isBot: bool = false
var trens: int = 45
var pontos: int = 45
var cor: int = 0
var cartas: Array[GameCard] = []
var cartas_destino = []
var cartas_coringa: int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func adicionarCartaNaMao(cartaParaAdicionar: GameCard):
	if cartaParaAdicionar not in cartas and cartaParaAdicionar != null:
		cartas.append(cartaParaAdicionar)
		if cartaParaAdicionar.card_index == 7: # Carta Coringa
			cartas_coringa += 1

func removerCartaDaMao(cartaParaRemover: GameCard):
	if cartaParaRemover in cartas:
		cartas.erase(cartaParaRemover)
		if cartaParaRemover.card_index == 7: # Carta Coringa
			cartas_coringa -= 1
			
func obterCartasMesmaCor(corDaCartaEscolhida:int, obterCoringas: bool = false) -> Array[GameCard]:
	var custom_sort_func = func custom_sort(a: GameCard, b: GameCard):
		return a.card_index < b.card_index
	
	var cartas_mesma_cor = cartas.filter(func(carta: GameCard) -> bool:
		return carta.card_index == corDaCartaEscolhida or (obterCoringas and carta.card_index == 7)
	)
	if (obterCoringas):
		cartas_mesma_cor.sort_custom(custom_sort_func)
	return cartas_mesma_cor


func capturarRotaBot(trilha_selecionada: TrilhaVagao, camera: Camera2D, gerenciadorDeFluxoRef: GerenciadorDeFluxo) -> void:
	if (!isBot): return;

	if trilha_selecionada and not trilha_selecionada.vagoes_array.is_empty():
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
				carta_instance.queue_free()
			)
