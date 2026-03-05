extends StaticBody2D

## An ore deposit in the world that the player can mine.

@export var ore_type: OreType

@onready var sprite: ColorRect = $Sprite
@onready var highlight: ColorRect = $Highlight
@onready var mining_progress_bar: ColorRect = $MiningProgressBar

var is_being_mined := false
var mine_progress := 0.0
var player_ref: Node = null

func _ready() -> void:
	highlight.visible = false
	mining_progress_bar.visible = false
	mining_progress_bar.size.x = 0
	if ore_type:
		sprite.color = ore_type.color

func _process(delta: float) -> void:
	if is_being_mined:
		mine_progress += delta
		var progress_ratio := mine_progress / ore_type.mine_time
		mining_progress_bar.size.x = 20.0 * progress_ratio
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
	mining_progress_bar.visible = true
	mining_progress_bar.size.x = 0
	EventBus.ore_mining_started.emit(self)

func _complete_mining() -> void:
	is_being_mined = false
	mining_progress_bar.visible = false
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
