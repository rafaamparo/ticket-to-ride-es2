extends Label
@export var href: String = ""
@export var button_name: String = "Novo Botão"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".text = button_name
	$".".uppercase = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$".".add_theme_color_override("font_color", "#bcfdb0")
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$".".add_theme_color_override("font_color", "#ffffff")
	pass # Replace with function body.

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
