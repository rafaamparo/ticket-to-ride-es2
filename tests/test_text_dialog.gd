extends GutTest

const TextDialogScene = preload("res://scenes/text_dialog.tscn")
var text_dialog

func before_each():
	text_dialog = TextDialogScene.instantiate()
	add_child_autofree(text_dialog)

func test_initial_state():
	assert_eq(text_dialog.dialog_text, "", "Initial dialog_text should be empty")
	assert_false(text_dialog.show_dialog, "Initial show_dialog should be false")

func test_set_dialog_text():
	text_dialog.set_dialog_text("Hello")
	assert_eq(text_dialog.dialog_text, "Hello", "dialog_text should be updated")

func test_show_dialog_with_text():
	await text_dialog.show_dialog_with_text("Test message")
	assert_true(text_dialog.show_dialog, "show_dialog should be true after showing")
	assert_eq(text_dialog.dialog_text, "Test message", "dialog_text should be set")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_eq(label.text, "Test message", "Label text should be updated")
	assert_true(label.is_visible(), "Label should be visible")
	assert_eq(text_dialog.modulate, Color(1, 1, 1, 1), "Dialog should be fully visible")

func test_hide_dialog():
	# First, show the dialog to ensure it's visible
	await text_dialog.show_dialog_with_text("A message")
	assert_true(text_dialog.show_dialog, "Pre-condition: show_dialog should be true")
	
	# Now, hide it
	await text_dialog.hide_dialog()
	assert_false(text_dialog.show_dialog, "show_dialog should be false after hiding")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_false(label.is_visible(), "Label should be hidden")
	assert_eq(text_dialog.modulate, Color(1, 1, 1, 0), "Dialog should be fully transparent")

func test_toggle_dialog_from_hidden_to_shown():
	text_dialog.dialog_text = "Toggled On"
	await text_dialog.toggle_dialog()
	assert_true(text_dialog.show_dialog, "Dialog should be shown after toggle")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_eq(label.text, "Toggled On", "Label text should be set after toggle")
	assert_true(label.is_visible(), "Label should be visible after toggle")

func test_toggle_dialog_from_shown_to_hidden():
	# First, show the dialog
	await text_dialog.show_dialog_with_text("Toggled Off")
	
	# Now, toggle it off
	await text_dialog.toggle_dialog()
	assert_false(text_dialog.show_dialog, "Dialog should be hidden after toggle")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_false(label.is_visible(), "Label should be hidden after toggle")

func test_set_dialog_text_when_visible():
	await text_dialog.show_dialog_with_text("Initial Text")
	text_dialog.set_dialog_text("Updated Text")
	assert_eq(text_dialog.dialog_text, "Updated Text", "dialog_text should be updated")
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_eq(label.text, "Updated Text", "Label text should be updated while visible")
