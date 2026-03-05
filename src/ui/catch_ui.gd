extends CanvasLayer

## Timing-bar minigame for catching wild cats.
## A marker moves back and forth; press interact when it's in the sweet spot.

@onready var panel: Panel = $Panel
@onready var bar_bg: ColorRect = $Panel/BarBG
@onready var sweet_spot: ColorRect = $Panel/BarBG/SweetSpot
@onready var marker: ColorRect = $Panel/BarBG/Marker
@onready var prompt_label: Label = $Panel/PromptLabel
@onready var cat_name_label: Label = $Panel/CatNameLabel
@onready var result_label: Label = $Panel/ResultLabel

var is_active := false
var marker_speed := 200.0
var marker_direction := 1.0
var current_wild_cat: Node = null
var sweet_spot_center := 0.5  # Normalized position
var sweet_spot_width := 0.3  # Normalized width (adjusted by difficulty)

const BAR_WIDTH := 200.0
const MARKER_WIDTH := 4.0

func _ready() -> void:
	visible = false
	EventBus.cat_catch_started.connect(_on_catch_started)

func _process(delta: float) -> void:
	if not is_active:
		return

	# Move the marker back and forth
	var marker_pos := marker.position.x + marker_speed * marker_direction * delta
	if marker_pos >= BAR_WIDTH - MARKER_WIDTH:
		marker_pos = BAR_WIDTH - MARKER_WIDTH
		marker_direction = -1.0
	elif marker_pos <= 0:
		marker_pos = 0
		marker_direction = 1.0
	marker.position.x = marker_pos

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("interact"):
		_check_catch()
		get_viewport().set_input_as_handled()

func _on_catch_started(wild_cat: Node) -> void:
	current_wild_cat = wild_cat
	var species: CatSpecies = wild_cat.species
	cat_name_label.text = species.display_name

	# Adjust difficulty
	sweet_spot_width = lerpf(0.4, 0.12, species.catch_difficulty)
	marker_speed = lerpf(150.0, 350.0, species.catch_difficulty)

	# Position sweet spot randomly
	sweet_spot_center = randf_range(0.2, 0.8)
	var spot_pixel_width := sweet_spot_width * BAR_WIDTH
	sweet_spot.position.x = sweet_spot_center * BAR_WIDTH - spot_pixel_width / 2.0
	sweet_spot.size.x = spot_pixel_width

	# Reset marker
	marker.position.x = 0
	marker_direction = 1.0

	result_label.text = ""
	prompt_label.text = "Press E when the marker is in the green zone!"
	visible = true
	is_active = true

func _check_catch() -> void:
	is_active = false

	var marker_center := marker.position.x + MARKER_WIDTH / 2.0
	var spot_left := sweet_spot.position.x
	var spot_right := sweet_spot.position.x + sweet_spot.size.x

	if marker_center >= spot_left and marker_center <= spot_right:
		# Success!
		result_label.text = "Caught!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
		await get_tree().create_timer(1.0).timeout
		visible = false
		current_wild_cat.catch_succeeded()
		_return_player_control()
	else:
		# Failed
		result_label.text = "Missed!"
		result_label.add_theme_color_override("font_color", Color.RED)
		await get_tree().create_timer(0.8).timeout
		visible = false
		current_wild_cat.catch_failed()
		_return_player_control()

func _return_player_control() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.set_player_state(player.State.IDLE)
