class_name TextDialog extends Control


var dialog_text: String = ""
var show_dialog: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await hide_dialog()  
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# function to show dialog, sets the dialog text and makes it visible using tween animation with fade in and scale effect
func show_dialog_with_text(text: String) -> void:
	dialog_text = text
	show_dialog = true
	var tween = create_tween()
	if tween:
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	$MarginContainer/VBoxContainer/Label.text = dialog_text
	$MarginContainer/VBoxContainer/Label.show()
	await tween.finished

# function to hide dialog, sets the dialog text to empty and makes it invisible using tween animation with fade out and scale effect
func hide_dialog() -> void:
	show_dialog = false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	$MarginContainer/VBoxContainer/Label.hide()
	await tween.finished
	
# function to toggle dialog visibility
func toggle_dialog() -> void:
	if show_dialog:
		await hide_dialog()
	else:
		await show_dialog_with_text(dialog_text)

# function to set dialog text
func set_dialog_text(text: String) -> void:
	dialog_text = text
	if show_dialog:
		$MarginContainer/VBoxContainer/Label.text = dialog_text
