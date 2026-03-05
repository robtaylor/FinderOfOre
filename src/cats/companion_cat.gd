extends Node2D

## The companion cat that follows the player and detects ores.
## Spawned/despawned when GameState.active_companion changes.

@onready var sprite: ColorRect = $Sprite
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/DetectionShape
@onready var indicator_arrow: Node2D = $IndicatorArrow

var cat_instance: CatInstance = null
var target_player: CharacterBody2D = null
var follow_offset := Vector2(-14, 4)
var follow_speed := 100.0
var detected_ores: Array = []
var nearest_ore: Node = null

func _ready() -> void:
	EventBus.companion_changed.connect(_on_companion_changed)
	indicator_arrow.visible = false
	visible = false

func _process(_delta: float) -> void:
	if not visible or not target_player:
		return

	# Follow the player with a slight lag
	var target_pos := target_player.global_position + follow_offset
	global_position = global_position.lerp(target_pos, 0.08)

	# Update ore indicator
	_update_indicator()

func _on_companion_changed(new_cat: CatInstance) -> void:
	if new_cat == null:
		visible = false
		cat_instance = null
		detected_ores.clear()
		nearest_ore = null
		indicator_arrow.visible = false
		return

	cat_instance = new_cat
	visible = true

	# Set color from species
	if cat_instance.species:
		sprite.color = cat_instance.species.color

	# Set detection radius
	var radius: float = cat_instance.get_detection_radius()
	var shape := CircleShape2D.new()
	shape.radius = radius
	detection_shape.shape = shape

	# Find player
	target_player = get_tree().get_first_node_in_group("player")
	if target_player:
		global_position = target_player.global_position + follow_offset

func _update_indicator() -> void:
	if detected_ores.is_empty():
		indicator_arrow.visible = false
		nearest_ore = null
		return

	# Find nearest matching ore
	var detectable := cat_instance.get_detectable_ores()
	var best_dist := INF
	nearest_ore = null

	for ore in detected_ores:
		if not is_instance_valid(ore):
			continue
		if ore.ore_type and ore.ore_type.ore_id in detectable:
			var dist := global_position.distance_to(ore.global_position)
			if dist < best_dist:
				best_dist = dist
				nearest_ore = ore

	if nearest_ore and is_instance_valid(nearest_ore):
		indicator_arrow.visible = true
		var dir: Vector2 = (nearest_ore.global_position - global_position).normalized()
		indicator_arrow.rotation = dir.angle()
		# Pulse effect
		var pulse := 0.7 + 0.3 * sin(Time.get_ticks_msec() / 300.0)
		indicator_arrow.modulate.a = pulse
		EventBus.ore_detected.emit(nearest_ore)
	else:
		indicator_arrow.visible = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("get_ore_type_data"):
		detected_ores.append(body)

func _on_detection_area_body_exited(body: Node2D) -> void:
	detected_ores.erase(body)
	if body == nearest_ore:
		nearest_ore = null
