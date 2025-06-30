# :ticket::mortar_board: Ticket to Class :mortar_board::ticket: 
Bem-vindo ao ***Ticket to Class***! O nosso trabalho consiste em desenvolver uma releitura do jogo ***Ticket to Ride*** para desktop. Seu objetivo é se tornar o aluno de maior prestígio do curso de Ciência da Computação da UFF. Para isso, você irá conectar disciplinas, cumprir objetivos de formação e acumular mais pontos que seus bots adversários. O jogo será desenvolvido a partir da engine ***Godot*** e a equipe será dividida em times de desenvolvimento e planejamento para maior eficiência e integração durante a implementação do projeto.

## :train: Modo de uso :train:

1. ***Início do Jogo***
<br>Ao iniciar uma partida, cada jogador recebe:
 * 6 Cartas de Vagão: Estas cartas representam as diferentes cores de vagão usadas para conectar as disciplinas no mapa.
 * 0 Cartas de Objetivo: Essas cartas mostram duas disciplinas que você deve conectar. Você deve escolher manter pelo menos duas delas. Objetivos concluídos rendem muitos pontos no final!

2. ***O seu Turno***
<br>Na sua vez, você deve realizar uma das três ações a seguir:
<br>a. Comprar Cartas de Vagão
<br>Você pode comprar até duas cartas de vagão. As opções são:
 * Pegar qualquer uma das cartas com a face para cima;
 * Pegar uma carta "às cegas" do topo do monte de compras.
 * Atenção: A carta multicolorida (Coringa) é especial e pode substituir qualquer cor. Se você pegá-la entre as cartas viradas para cima, ela conta como sua única compra daquele turno.

<br>b. Pegar Novas Cartas de Objetivo
<br>Você pode comprar mais 3 Cartas de Objetivo para tentar aumentar sua pontuação final. Você deve obrigatoriamente ficar com pelo menos uma das três novas cartas.

<br>c. Conectar Disciplinas
<br>Para conectar duas disciplinas adjacentes no mapa, você deve jogar um conjunto de Cartas de Vagão correspondente à cor e ao número de espaços da rota. Por exemplo, para uma rota azul de 3 espaços, você deve baixar 3 cartas de crédito azuis.
 * Rotas cinzas podem ser reivindicadas com cartas de qualquer cor, desde que todas sejam da mesma cor.
 * Ao conectar disciplinas, você ganha pontos imediatamente, baseados no tamanho da rota.

**Comprimento da Rota** | **Pontos** |
:---------------------: | :--------: |
1 | 1 |
2 | 2 |
3 | 4 |
4 | 7 |
5 | 10 |
6 | 15 |
7 | 21 |
8 | 28 |


3. ***Fim de Jogo***
<br>O final do jogo é acionado quando um jogador fica com 2 ou menos peças de conexão. 

4. ***Pontuação Final***
<br>Após a última rodada, a pontuação final é calculada:
 * Pontos das Rotas: Soma de todos os pontos obtidos ao conectar disciplinas durante o jogo.
 * Bônus dos Objetivos: Adiciona-se o valor de cada Carta de Objetivo que foi completada com sucesso.
 * Bônus "Formando Destaque": O jogador que construiu o maior caminho contínuo de disciplinas conectadas ganha um bônus.
O jogador com o maior número de pontos ao final é declarado o vencedor e o aluno de maior prestígio da turma!

## :busts_in_silhouette: Equipe
* :bar_chart: Rafael - Gestor de projeto 
* :gear: Júlia - Gerente de planejamento
* :gear: João Gabriel - Gerente de desenvolvimento
* :chart_with_upwards_trend: Beatriz - Analista de projeto
* :computer: Carina - Desenvolvedora
* :computer: Thales - Desenvolvedor

## Progresso

#### Iteração I
  ![](https://geps.dev/progress/100?dangerColor=800000&warningColor=ff9900&successColor=006600)

#### Iteração II 
  ![](https://geps.dev/progress/100?dangerColor=800000&warningColor=ff9900&successColor=006600)

#### Iteração III 
  ![](https://geps.dev/progress/100?dangerColor=800000&warningColor=ff9900&successColor=006600)

## :calendar: Cronograma
### Iteração I (11/04 - 05/05)
- [X] Estudo do Produto Original
- [X] Elaboração EAP
- [X] Levantamento de Requisitos do Produto
- [X] Pesquisa Técnica
- [X] Pesquisa de Jogabilidade
- [X] Estimativa de Esforço PP
- [X] Estimativa de Esforço APF
- [X] Análise de Riscos
- [X] Definição do Orçamento e do Custo
- [X] Prototipagem do Produto
- [X] Definição do Cronograma de Desenvolvimento (GANTT)
- [X] Análise da Sprint - Monitoramento e Controle

### Iteração II (05/05 - 01/06)
- [x] Desenvolvimento da pipeline de integração contínua
- [x] Implementar Sistema de Mapa Interativo
- [x] Implementar lógica de conexão entre cidades
- [x] Sistema de decks de cartas
- [x] Desenvolvimento do sistema para reivindicação de rotas
- [x] Sistema de compra de cartas
- [x] Sistema de turnos
- [x] Sistema de cálculo de pontos
- [x] Menu Principal e Configurações
- [x] Validação da Demo (Entrega da Sprint)
- [x] Criação de Testes das funcionalidades básicas
- [x] Análise da Sprint

### Iteração III (03/06 - 30/06)
- [x] Sistema de compra de cartas
- [x] Sistema de turnos
- [x] Menu Principal e Configurações
- [x] Criação de Testes das funcionalidades básicas
- [x] Implementação da jogabilidade com bots
- [x] Testes Unitários
- [x] Testes de Integração
- [x] Testes de Usabilidade
- [x] Testes de Aceitação
- [x] Relatório de Testes
- [x] Validação Final - Produto
- [x] Empacotamento da Aplicação
- [x] Documentação do Usuário
- [x] Análise da Sprint
- [x] Análise Final do Projeto

## Links úteis 
+ [:link:](https://drive.google.com/drive/folders/1cuiLI-nLHgZQftqxqwLhmsISwi6Ljx0f?usp=drive_link) Google Drive - imagens, documentos e relatórios gerados durante o desenvolvimento do jogo.
+ [:link:](https://www.canva.com/design/DAGmO0nm1Io/6k_SZDvsDn_vYE2s3cZuHA/view?utm_content=DAGmO0nm1Io&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h14eb927491) Primeira apresentação - apresentação de slides utilizada na primeira entrega do projeto.
+ [:link:](https://www.canva.com/design/DAGoTfS5UDs/SqobLz9NjghUm6eEAiyMbQ/view?utm_content=DAGoTfS5UDs&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h291b6ab2b8) Segunda apresentação - apresentação de slides utilizada na segunda entrega do projeto
+ [:link:](https://www.canva.com/design/DAGrNUDKn1Q/lUBo7IiZAtTrV5JFv-8QPw/view?utm_content=DAGrNUDKn1Q&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h9591ce9e56) Terceira apresentação - apresentação de slides utilizada na terceira entrega do projeto
