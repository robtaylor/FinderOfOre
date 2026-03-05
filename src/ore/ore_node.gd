extends StaticBody2D

## An ore deposit in the world that the player can mine.

@export var ore_type: OreType

@onready var sprite: Sprite2D = $Sprite
@onready var highlight: Sprite2D = $Highlight
@onready var progress_bg: ColorRect = $ProgressBG
@onready var progress_fill: ColorRect = $ProgressFill

var is_being_mined := false
var mine_progress := 0.0
var player_ref: Node = null

const PROGRESS_BAR_WIDTH := 30.0

func _ready() -> void:
	highlight.visible = false
	progress_bg.visible = false
	progress_fill.visible = false
	if ore_type:
		# Load ore-specific sprite
		var tex_path := "res://assets/sprites/ores/%s.png" % ore_type.ore_id
		var tex := load(tex_path)
		if tex:
			sprite.texture = tex
			highlight.texture = tex

func _process(delta: float) -> void:
	if is_being_mined:
		mine_progress += delta
		var progress_ratio := mine_progress / ore_type.mine_time
		progress_fill.size.x = PROGRESS_BAR_WIDTH * progress_ratio
		if mine_progress >= ore_type.mine_time:
			_complete_mining()

func interact(player: Node) -> void:
	if is_being_mined:
		return
	if not ore_type:
		push_warning("OreNode has no ore_type assigned!")
		return
	player_ref = player
	player.set_player_state(player.State.MINING)
	is_being_mined = true
	mine_progress = 0.0
	progress_bg.visible = true
	progress_fill.visible = true
	progress_fill.size.x = 0
	EventBus.ore_mining_started.emit(self)

func _complete_mining() -> void:
	is_being_mined = false
	progress_bg.visible = false
	progress_fill.visible = false
	GameState.add_ore(ore_type.ore_id)
	EventBus.ore_mining_completed.emit(self, ore_type)

	if player_ref:
		player_ref.set_player_state(player_ref.State.IDLE)
		if GameState.active_companion:
			GameState.active_companion.total_ores_found += 1
		player_ref = null

	# Respawn after a delay (ore regenerates)
	sprite.visible = false
	highlight.visible = false
	collision_layer = 0
	await get_tree().create_timer(10.0).timeout
	mine_progress = 0.0
	sprite.visible = true
	collision_layer = 8  # Layer 4: OreNodes

func get_ore_type_data() -> OreType:
	return ore_type

func show_highlight() -> void:
	highlight.visible = true

func hide_highlight() -> void:
	highlight.visible = false
