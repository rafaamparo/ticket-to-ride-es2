extends GdUnitTestSuite

const TextDialogScene = preload("res://scenes/text_dialog.tscn")
var text_dialog : Node

func before() -> void:
	text_dialog = auto_free(TextDialogScene.instantiate())
	get_tree().get_root().add_child(text_dialog)

func test_initial_state() -> void:
	assert_str(text_dialog.dialog_text).is_empty()
	assert_bool(text_dialog.show_dialog).is_false()

func test_set_dialog_text() -> void:
	text_dialog.set_dialog_text("Hello")
	assert_str(text_dialog.dialog_text).is_equal("Hello")

func test_show_dialog_with_text() -> void:
	await text_dialog.show_dialog_with_text("Test message")
	assert_bool(text_dialog.show_dialog).is_true()
	assert_str(text_dialog.dialog_text).is_equal("Test message")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_str(label.text).is_equal("Test message")
	assert_bool(label.is_visible()).is_true()

func test_hide_dialog() -> void:
	await text_dialog.show_dialog_with_text("A message")
	assert_bool(text_dialog.show_dialog).is_true()

	await text_dialog.hide_dialog()
	assert_bool(text_dialog.show_dialog).is_false()
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_bool(label.is_visible()).is_false()

func test_toggle_dialog_from_hidden_to_shown() -> void:
	text_dialog.dialog_text = "Toggled On"
	await text_dialog.toggle_dialog()
	assert_bool(text_dialog.show_dialog).is_true()
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_str(label.text).is_equal("Toggled On")
	assert_bool(label.is_visible()).is_true()

func test_toggle_dialog_from_shown_to_hidden() -> void:
	await text_dialog.show_dialog_with_text("Toggled Off")
	await text_dialog.toggle_dialog()
	assert_bool(text_dialog.show_dialog).is_false()
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_bool(label.is_visible()).is_false()

func test_set_dialog_text_when_visible() -> void:
	await text_dialog.show_dialog_with_text("Initial Text")
	text_dialog.set_dialog_text("Updated Text")
	assert_str(text_dialog.dialog_text).is_equal("Updated Text")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_str(label.text).is_equal("Updated Text")
