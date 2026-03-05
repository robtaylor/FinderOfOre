extends CanvasLayer

## Backpack UI showing caught cats with ability to set companion.

@onready var panel: Panel = $Panel
@onready var cat_list: VBoxContainer = $Panel/ScrollContainer/CatList
@onready var title_label: Label = $Panel/TitleLabel
@onready var close_button: Button = $Panel/CloseButton

var is_open := false

func _ready() -> void:
	visible = false
	EventBus.backpack_opened.connect(_open)
	close_button.pressed.connect(_close)

func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("open_backpack") or event.is_action_pressed("ui_cancel")):
		_close()
		get_viewport().set_input_as_handled()

func _open() -> void:
	_refresh_list()
	visible = true
	is_open = true
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.set_player_state(player.State.DIALOGUE)

func _close() -> void:
	visible = false
	is_open = false
	EventBus.backpack_closed.emit()
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.set_player_state(player.State.IDLE)

func _refresh_list() -> void:
	# Clear existing entries
	for child in cat_list.get_children():
		child.queue_free()

	title_label.text = "Backpack (%d/%d)" % [GameState.backpack.size(), GameState.BACKPACK_CAPACITY]

	if GameState.backpack.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No cats caught yet!"
		cat_list.add_child(empty_label)
		return

	for cat_inst in GameState.backpack:
		var entry := _create_cat_entry(cat_inst)
		cat_list.add_child(entry)

func _create_cat_entry(cat_inst: CatInstance) -> HBoxContainer:
	var hbox := HBoxContainer.new()

	# Color swatch
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(12, 12)
	swatch.color = cat_inst.species.color if cat_inst.species else Color.WHITE
	hbox.add_child(swatch)

	# Name
	var name_label := Label.new()
	var is_active := (cat_inst == GameState.active_companion)
	var suffix := " [ACTIVE]" if is_active else ""
	name_label.text = " %s%s" % [cat_inst.get_display_name(), suffix]
	name_label.custom_minimum_size.x = 120
	hbox.add_child(name_label)

	# Detects label
	var detects_label := Label.new()
	var ores_str := ", ".join(cat_inst.get_detectable_ores())
	detects_label.text = "Detects: %s" % ores_str
	detects_label.custom_minimum_size.x = 100
	hbox.add_child(detects_label)

	# Set Companion button
	var btn := Button.new()
	if is_active:
		btn.text = "Remove"
		btn.pressed.connect(func(): _remove_companion())
	else:
		btn.text = "Set Active"
		btn.pressed.connect(func(): _set_companion(cat_inst))
	hbox.add_child(btn)

	return hbox

func _set_companion(cat_inst: CatInstance) -> void:
	GameState.set_companion(cat_inst)
	_refresh_list()

func _remove_companion() -> void:
	GameState.remove_companion()
	_refresh_list()
