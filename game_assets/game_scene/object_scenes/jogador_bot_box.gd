class_name JogadorBotBox extends Control


var jogadorSelecionado: Jogador = null
const cores_dict = [
	{
		"cor": "Azul",
		"textura_caixa": "res://game_assets/game_scene/object_scenes/UI/menu_azul2.png",
		"textura_jogador": "res://game_assets/game_scene/object_scenes/UI/azul.png"
	},
	{
		"cor": "Verde",
		"textura_caixa": "res://game_assets/game_scene/object_scenes/UI/menu_verde.png",
		"textura_jogador": "res://game_assets/game_scene/object_scenes/UI/verde.png"
	},
		{
		"cor": "Amarelo",
		"textura_caixa": "res://game_assets/game_scene/object_scenes/UI/menu_amarelo.png",
		"textura_jogador": "res://game_assets/game_scene/object_scenes/UI/amarelo.png",
	},
	{
		"cor": "Vermelho",
		"textura_caixa": "res://game_assets/game_scene/object_scenes/UI/menu_vermelho.png",
		"textura_jogador": "res://game_assets/game_scene/object_scenes/UI/vermelho.png"
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Nome.text = jogadorSelecionado.nome;
	#$bilhetes.text = str(len(jogadorSelecionado.cartas_destino))
	$pontos.text = str(jogadorSelecionado.pontos)
	$trens.text = str(jogadorSelecionado.trens)
	
	if $TexturaFundo:
		$TexturaFundo.texture = load(cores_dict[jogadorSelecionado.cor]["textura_caixa"])
	if $Personagem:
		$Personagem.texture = load(cores_dict[jogadorSelecionado.cor]["textura_jogador"])
	pass
