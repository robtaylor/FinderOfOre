extends CanvasLayer

## Dialogue box with typewriter text effect.

signal dialogue_finished

@onready var panel: Panel = $Panel
@onready var text_label: Label = $Panel/TextLabel
@onready var continue_label: Label = $Panel/ContinueLabel

var lines: Array[String] = []
var current_line_index := 0
var current_char_index := 0
var is_active := false
var is_typing := false
var type_speed := 0.03  # seconds per character
var type_timer := 0.0

func _ready() -> void:
	visible = false
	add_to_group("dialogue_ui")
	continue_label.text = "[E] Continue"

func _process(delta: float) -> void:
	if not is_active:
		return

	if is_typing:
		type_timer += delta
		while type_timer >= type_speed and current_char_index < lines[current_line_index].length():
			current_char_index += 1
			type_timer -= type_speed
			text_label.text = lines[current_line_index].substr(0, current_char_index)

		if current_char_index >= lines[current_line_index].length():
			is_typing = false
			continue_label.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("interact"):
		if is_typing:
			# Skip to end of line
			current_char_index = lines[current_line_index].length()
			text_label.text = lines[current_line_index]
			is_typing = false
			continue_label.visible = true
		else:
			# Next line or close
			current_line_index += 1
			if current_line_index >= lines.size():
				_close()
			else:
				_start_typing()
		get_viewport().set_input_as_handled()

func show_dialogue(dialogue_lines: Array[String]) -> void:
	lines = dialogue_lines
	current_line_index = 0
	visible = true
	is_active = true
	_start_typing()

func _start_typing() -> void:
	current_char_index = 0
	type_timer = 0.0
	is_typing = true
	text_label.text = ""
	continue_label.visible = false

func _close() -> void:
	visible = false
	is_active = false
	dialogue_finished.emit()
