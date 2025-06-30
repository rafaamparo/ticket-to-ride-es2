class_name GerenciadorCartasDestino extends Node

var gerenciador_fluxo: GerenciadorDeFluxo = null
var gerenciador_de_trilhas: GerenciadorDeTrilhas = null
var gerenciador_de_paradas: GerenciadorDeParadas = null
var destino_text_dialog: PLayerDestinoDialog = null
var cartas_destino_turno: Array[CartaDestino] = []
var cartas_recusadas_turno: Array[CartaDestino] = []
var mostrandoBox: bool = false;


var mapeamento_cartas_destino = null

var cartas_de_destino_disponiveis = [
	 {
	 	"origem": "Calculo1",
	 	"destino": "MetodosNumericos",
	 	"pontuacao": 36
	 },
	 {
	 	"origem": "Fisica",
	 	"destino": "BD1",
	 	"pontuacao": 60
	 },
	{
		"origem": "Calculo1",
		"destino": "Algelin",
		"pontuacao": 100
	},
	 {
	 	"origem": "Calculo1",
	 	"destino": "PesquisaOperacional",
	 	"pontuacao": 21
	 },
	 {
	 	"origem": "Algelin",
	 	"destino": "APA",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "GA",
	 	"destino": "POO",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "ProgI",
	 	"destino": "BD1",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "ProgI",
	 	"destino": "ES2",
	 	"pontuacao": 15
	 },
	 {
	 	"origem": "FAC",
	 	"destino": "BD1",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Logica",
	 	"destino": "ED",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Fisexp",
	 	"destino": "IHC",
	 	"pontuacao": 36
	 },
	 {
	 	"origem": "ED",
	 	"destino": "BD2",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "LP",
	 	"destino": "MetodosNumericos",
	 	"pontuacao": 85
	 },
	 {
	 	"origem": "MetodosNumericos",
	 	"destino": "R2",
	 	"pontuacao": 85
	 },
	 {
	 	"origem": "Logica",
	 	"destino": "SO",
	 	"pontuacao": 85
	 },
	 {
	 	"origem": "GA",
	 	"destino": "IA",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "ProbEst",
	 	"destino": "Compiladores",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "PesquisaOperacional",
	 	"destino": "BD2",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "FAC",
	 	"destino": "MatDiscreta",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Calculo2",
	 	"destino": "ES1",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "ProgI",
	 	"destino": "IHC",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "ProgEstruturada",
	 	"destino": "AlgGrafos",
	 	"pontuacao": 36
	 },
	 {
	 	"origem": "APA",
	 	"destino": "ARQ",
	 	"pontuacao": 28
	 },
	 {
	 	"origem": "Algelin",
	 	"destino": "SO",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Calculo1",
	 	"destino": "ES2",
	 	"pontuacao": 85
	 },
	 {
	 	"origem": "LabJogos",
	 	"destino": "IHC",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "R1",
	 	"destino": "MatDiscreta",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "ED",
	 	"destino": "ARQ",
	 	"pontuacao": 7
	 },
	 {
	 	"origem": "LP",
	 	"destino": "ES1",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Calculo2",
	 	"destino": "ProgCientifica",
	 	"pontuacao": 28
	 },
	 {
	 	"origem": "Algelin",
	 	"destino": "ED",
	 	"pontuacao": 28
	 },
	 {
	 	"origem": "MetodosNumericos",
	 	"destino": "BD1",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "ProgI",
	 	"destino": "ES2",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "SD",
	 	"destino": "Logica",
	 	"pontuacao": 85
	 },
	 {
	 	"origem": "SO",
	 	"destino": "BD2",
	 	"pontuacao": 60
	 },
	 {
	 	"origem": "ES1",
	 	"destino": "Fisica",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "Calculo1",
	 	"destino": "BD1",
	 	"pontuacao": 75
	 },
	 {
	 	"origem": "R2",
	 	"destino": "ProbEst",
	 	"pontuacao": 75
	 }
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerenciador_fluxo = $"../../GerenciadorDeFluxoJogo";
	gerenciador_de_trilhas = $"../../GerenciadorDeTrilhas";
	gerenciador_de_paradas = $"../../GerenciadordeParadas";
	destino_text_dialog = $"../Destino-dialog";
	mapeamento_cartas_destino = {
		"Calculo1": $"../../GerenciadordeParadas/Calculo1",
		"Fisica": $"../../GerenciadordeParadas/Física",
		"GA": $"../../GerenciadordeParadas/GA",
		"Algelin": $"../../GerenciadordeParadas/Algelin",
		"ProbEst": $"../../GerenciadordeParadas/ProbEst",
		"AvD": $"../../GerenciadordeParadas/AvD",
		"Calculo2": $"../../GerenciadordeParadas/Calculo2",
		"MetodosNumericos": $"../../GerenciadordeParadas/MetodosNumericos",
		"LP": $"../../GerenciadordeParadas/LP",
		"Fisexp": $"../../GerenciadordeParadas/FisicaExperimental",
		"PesquisaOperacional": $"../../GerenciadordeParadas/PesquisaOperacional",
		"ProgCientifica": $"../../GerenciadordeParadas/ProgCientifica",
		"Logica": $"../../GerenciadordeParadas/Logica",
		"MatDiscreta": $"../../GerenciadordeParadas/MatDiscreta",
		"Compiladores": $"../../GerenciadordeParadas/Compiladores",
		"AlgGrafos": $"../../GerenciadordeParadas/AlgGrafos",
		"APA": $"../../GerenciadordeParadas/APA",
		"LabMoveis": $"../../GerenciadordeParadas/LabMoveis",
		"LabJogos": $"../../GerenciadordeParadas/LabJogos",
		"ProgI": $"../../GerenciadordeParadas/ProgI",
		"ProgEstruturada": $"../../GerenciadordeParadas/ProgEstruturada",
		"ED": $"../../GerenciadordeParadas/ED",
		"BD1": $"../../GerenciadordeParadas/BDI",
		"BD2": $"../../GerenciadordeParadas/BDII",
		"IHC": $"../../GerenciadordeParadas/IHC",
		"ES1": $"../../GerenciadordeParadas/ES1",
		"POO": $"../../GerenciadordeParadas/POO",
		"IA": $"../../GerenciadordeParadas/IA",
		"PS": $"../../GerenciadordeParadas/PS",
		"ES2": $"../../GerenciadordeParadas/ES2",
		"R1": $"../../GerenciadordeParadas/R1",
		"R2": $"../../GerenciadordeParadas/R2",
		"SD": $"../../GerenciadordeParadas/SD",
		"SO": $"../../GerenciadordeParadas/SO",
		"ARQ": $"../../GerenciadordeParadas/ARQ",
		"CD": $"../../GerenciadordeParadas/CD",
		"FAC": $"../../GerenciadordeParadas/FAC",
	}
	atualizarTurnoDestino()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if cartas_destino_turno.size() + cartas_recusadas_turno.size() >= 3 and gerenciador_fluxo.pausar_jogador_principal == false:
		gerenciador_fluxo.acao_jogador_terminada.emit()

func atualizarTurnoDestino() -> void:
	cartas_destino_turno.clear()
	cartas_recusadas_turno.clear()

func verificarSeJogadorFezCaminho(jogador: Jogador, parada1: Parada, parada2: Parada) -> bool:
	var trilhas_capturadas = jogador.caminhosCapturados
	
	var fila: Array[Parada] = [parada1]
	var visitados: Array[Parada] = [parada1]
	
	while not fila.is_empty():
		print("Explorando caminho de %s para %s" % [parada1.nomeDaParada, parada2.nomeDaParada])
		var parada_atual = fila.pop_front()
		print("Parada atual: %s" % parada_atual.nomeDaParada)
		
		if parada_atual == parada2:
			return true
			
		for trilha in trilhas_capturadas:
			var proxima_parada: Parada = null
			if trilha.parada1 == parada_atual:
				proxima_parada = trilha.parada2
			elif trilha.parada2 == parada_atual:
				proxima_parada = trilha.parada1
			
			if proxima_parada != null and not proxima_parada in visitados:
				visitados.append(proxima_parada)
				fila.append(proxima_parada)
				
	return false


func pegarCartaDestinoBaralho(jogador: Jogador) -> void:
	var carta_gerada:CartaDestino = gerarCartaDestino(jogador);

	if jogador.isBot:
		cartas_destino_turno.append(carta_gerada)
		jogador.cartas_destino.append(carta_gerada)
	else:
		if cartas_recusadas_turno.size() >= 2:
			await destino_text_dialog.show_dialog_box(carta_gerada, true);
			mostrandoBox = true
		else:
			await destino_text_dialog.show_dialog_box(carta_gerada);
			mostrandoBox = true
		var acao_do_jogador = await destino_text_dialog.response_received
		
		if (acao_do_jogador == 1):
			cartas_destino_turno.append(carta_gerada)
			jogador.cartas_destino.append(carta_gerada)
		else:
			cartas_recusadas_turno.append(carta_gerada)
		
		destino_text_dialog.hide_dialog()
		mostrandoBox = false


func gerarCartaDestino(jogador: Jogador) -> CartaDestino:
	var carta_escolhida = cartas_de_destino_disponiveis.pick_random()

	var instanciador = CartaDestino.new()

	var carta_destino = instanciador.criar_carta(
		mapeamento_cartas_destino.get(carta_escolhida["origem"]),
		mapeamento_cartas_destino.get(carta_escolhida["destino"]),
		carta_escolhida["pontuacao"],
	)

	return carta_destino

	
