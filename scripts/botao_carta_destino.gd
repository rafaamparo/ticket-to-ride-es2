class_name BotaoCartaDestino extends Button

var texturaBotao: TextureRect = null
var original_position_x: float
var gerenciadorDeComprarCartas: GerenciadorComprarCartas = null
var gerenciadorDeFluxoDeJogo: GerenciadorDeFluxo = null
var desativado : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Obtém a referência do gerenciador de compras de cartas
	gerenciadorDeComprarCartas = $"../GerenciadorComprarCartas";
	gerenciadorDeFluxoDeJogo = $"../../GerenciadorDeFluxoJogo";
	texturaBotao = $TexturaBotao
	original_position_x = texturaBotao.position.x
	
	# Conectar os sinais do botão às funções de animação
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)

# Animação quando o mouse entra na área do botão
func _on_mouse_entered() -> void:
	if desativado: return;
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(texturaBotao, "position:x", original_position_x - 10, 0.2)

# Animação quando o mouse sai da área do botão
func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(texturaBotao, "position:x", original_position_x, 0.2)

# Animação quando o botão é pressionado
func _on_button_pressed() -> void:
	if desativado: return;
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	# Anima o scale para um valor menor
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
	# Anima o scale de volta ao normal
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)


func verificaSePodeApertarBotao() -> bool:
	return gerenciadorDeComprarCartas.verificarSePodePegarDoBaralho()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if gerenciadorDeFluxoDeJogo.pausar_jogador_principal or not verificaSePodeApertarBotao():
		texturaBotao.modulate = Color(0.5, 0.5, 0.5, 1)  # Deixa o botão escuro
		desativado = true
	else:
		texturaBotao.modulate = Color(1, 1, 1, 1)  # Deixa o botão normal
		desativado = false


#func comprarCartaBaralho(jogador: Jogador, cartaGerada: GameCard = null) -> void:
	#gerenciadorDeComprarCartas.comprarCartaDoBaralho(jogador, cartaGerada)
