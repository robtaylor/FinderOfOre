extends CanvasLayer

## Heads-up display showing ore count, active cat, and reputation.

@onready var ore_label: Label = $HUD/OreLabel
@onready var cat_label: Label = $HUD/CatLabel
@onready var cat_swatch: ColorRect = $HUD/CatSwatch
@onready var reputation_label: Label = $HUD/ReputationLabel

func _ready() -> void:
	EventBus.companion_changed.connect(_on_companion_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	EventBus.ore_mining_completed.connect(_on_ore_mined)
	EventBus.ore_delivered.connect(_on_ore_delivered)
	_update_ore_display()
	_update_cat_display()
	_update_reputation_display()

func _on_companion_changed(_cat: CatInstance) -> void:
	_update_cat_display()

func _on_reputation_changed(_new_value: int) -> void:
	_update_reputation_display()

func _on_ore_mined(_ore_node: Node, _ore_type: OreType) -> void:
	_update_ore_display()

func _on_ore_delivered(_ore_id: String, _amount: int) -> void:
	_update_ore_display()

func _update_ore_display() -> void:
	var total := GameState.get_total_ore_count()
	ore_label.text = "Ore: %d" % total

func _update_cat_display() -> void:
	if GameState.active_companion:
		cat_label.text = GameState.active_companion.get_display_name()
		cat_swatch.color = GameState.active_companion.species.color
		cat_swatch.visible = true
	else:
		cat_label.text = "No companion"
		cat_swatch.visible = false

func _update_reputation_display() -> void:
	reputation_label.text = "Rep: %d" % GameState.reputation
