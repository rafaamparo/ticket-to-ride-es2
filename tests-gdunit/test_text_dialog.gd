extends GdUnitTestSuite

const TextDialogScene = preload("res://scenes/text_dialog.tscn")
var text_dialog: Control

func before_test_case():
	text_dialog = auto_free(TextDialogScene.instantiate())
	add_child(text_dialog)

func test_initial_state():
	assert_that(text_dialog.dialog_text).is_equal_to("")
	assert_that(text_dialog.show_dialog).is_false()
func test_set_dialog_text():
	text_dialog.set_dialog_text("Hello")
	assert_that(text_dialog.dialog_text).is_equal_to("Hello")

func test_show_dialog_with_text():
	await text_dialog.show_dialog_with_text("Test message")
	assert_that(text_dialog.show_dialog).is_true()
	assert_that(text_dialog.dialog_text).is_equal_to("Test message")
	
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_that(label.text).is_equal_to("Test message")
	assert_that(label.is_visible()).is_true()
	assert_that(text_dialog.modulate).is_equal_to(Color(1, 1, 1, 1))

func test_hide_dialog():
	# First, show the dialog to ensure it's visible
	await text_dialog.show_dialog_with_text("A message")
	assert_that(text_dialog.show_dialog).is_true()
	
	# Now, hide it
	await text_dialog.hide_dialog()
	assert_that(text_dialog.show_dialog).is_false()
	
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_that(label.is_visible()).is_false()
	assert_that(text_dialog.modulate).is_equal_to(Color(1, 1, 1, 0))

func test_toggle_dialog_from_hidden_to_shown():
	text_dialog.dialog_text = "Toggled On"
	await text_dialog.toggle_dialog()
	assert_that(text_dialog.show_dialog).is_true()
	
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_that(label.text).is_equal_to("Toggled On")
	assert_that(label.is_visible()).is_true()

func test_toggle_dialog_from_shown_to_hidden():
	# First, show the dialog
	await text_dialog.show_dialog_with_text("Toggled Off")
	
	# Now, toggle it off
	await text_dialog.toggle_dialog()
	assert_that(text_dialog.show_dialog).is_false()
	
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_that(label.is_visible()).is_false()

func test_set_dialog_text_when_visible():
	await text_dialog.show_dialog_with_text("Initial Text")
	text_dialog.set_dialog_text("Updated Text")
	assert_that(text_dialog.dialog_text).is_equal_to("Updated Text")
	
	var label = text_dialog.get_node("MarginContainer/VBoxContainer/Label")
	assert_that(label.text).is_equal_to("Updated Text")
