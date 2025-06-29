extends HBoxContainer

var ranking_position: int = 0
var playerName = ""
var points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PlayerName.text = str(ranking_position) + ". " + playerName
	$Points.text = str(points) + " Pontos"
	pass
