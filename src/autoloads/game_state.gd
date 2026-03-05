extends Node

const BACKPACK_CAPACITY := 100

var backpack: Array = []  # Array of CatInstance
var ore_inventory: Dictionary = {}  # ore_id -> count
var active_companion = null  # CatInstance or null
var reputation: int = 0

func add_cat(cat_instance) -> bool:
	if backpack.size() >= BACKPACK_CAPACITY:
		return false
	backpack.append(cat_instance)
	return true

func set_companion(cat_instance) -> void:
	active_companion = cat_instance
	EventBus.companion_changed.emit(cat_instance)

func add_ore(ore_id: String, amount: int = 1) -> void:
	if ore_inventory.has(ore_id):
		ore_inventory[ore_id] += amount
	else:
		ore_inventory[ore_id] = amount

func deliver_all_ore() -> int:
	var total_value := 0
	for ore_id in ore_inventory:
		var count: int = ore_inventory[ore_id]
		total_value += count  # Will multiply by ore base_value later
		EventBus.ore_delivered.emit(ore_id, count)
	ore_inventory.clear()
	reputation += total_value
	EventBus.reputation_changed.emit(reputation)
	return total_value

func get_ore_count(ore_id: String) -> int:
	return ore_inventory.get(ore_id, 0)

func get_total_ore_count() -> int:
	var total := 0
	for count in ore_inventory.values():
		total += count
	return total
