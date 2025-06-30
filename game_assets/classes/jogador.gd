class_name Jogador extends Node2D

const QTD_CARTAS_BOT = 6
var nome: String = "Jogador BOT"
var isBot: bool = false
var trens: int = Globals.qtd_trens_inicio
var pontos: int = 0
var cor: int = 0
var cartas: Array[GameCard] = []
var caminhosCapturados: Array[TrilhaVagao] = []
var cartas_destino: Array[CartaDestino] = []
var cartas_coringa: int = 0
var player_info_box: JogadorBotBox = null



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trens = Globals.qtd_trens_inicio
	pass


func gerarCartasBot() -> void:
	if (!isBot): return;
	var carta_scene = preload("res://game_assets/game_scene/object_scenes/game_card_scene.tscn")
	for i in range(Globals.qtd_cartas_inicio):
		var carta = carta_scene.instantiate()
		var cor_aleatoria = randi_range(0,7)
		if cor_aleatoria == 7 and self.cartas_coringa >= 2:
			cor_aleatoria = randi_range(0,6)
		
		carta.card_index = cor_aleatoria
		self.adicionarCartaNaMao(carta);


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


func capturarRotaBot(gerenciador_trilhas_ref: GerenciadorDeTrilhas) -> bool:
	if (!isBot): return false;

	var trilhas_nao_capturadas = gerenciador_trilhas_ref.lista_trilhas.filter(func(trilha: TrilhaVagao) -> bool:
		return not trilha.capturado
	)

	trilhas_nao_capturadas.shuffle() # Embaralha as trilhas não capturadas para capturar aleatoriamente

	for trilha in trilhas_nao_capturadas:
		# percorre todas as trilhas não capturadas, para cada trilha, verifica se o jogador tem cartas da mesma cor ou coringas suficientes
		print("Tentando capturar a trilha: ", trilha.name, " com cor: ", trilha.cor_trilha)
		print("Número de cartas na mão: ", cartas.size())
		
		var cartas_da_mesma_cor = obterCartasMesmaCor(trilha.cores_map[trilha.cor_trilha], true)
		var num_vagoes_necessarios = trilha.get_qtd_vagoes()
		if cartas_da_mesma_cor.size() < num_vagoes_necessarios:
			continue

		# Se chegou aqui, o jogador tem cartas suficientes para capturar a trilha

		var cartas_a_serem_usadas = cartas_da_mesma_cor.slice(0, num_vagoes_necessarios)
		await gerenciador_trilhas_ref.animacaoCapturaTrilha(trilha, cartas_a_serem_usadas)

		# Atualiza as cartas do jogador, removendo as usadas. Depois chamar a função de captura da trilha e subtrair os pontos
		for carta_usada in cartas_a_serem_usadas:
			removerCartaDaMao(carta_usada)
			if is_instance_valid(carta_usada):
				carta_usada.queue_free()
		if trilha.cores_map[trilha.cor_trilha] == 7:
			trilha.cor_trilha = trilha.cores_map_reverse[cartas_a_serem_usadas[0].card_index]
		trilha.capturar_trilha(self)
		self.caminhosCapturados.append(trilha)
		pontos += trilha.pontos_da_trilha
		trens -= num_vagoes_necessarios
		caminhosCapturados.append(trilha)
		return true # Capturou uma rota com sucesso
	return false # Não conseguiu capturar nenhuma rota
