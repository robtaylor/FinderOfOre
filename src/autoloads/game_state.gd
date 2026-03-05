extends Node

const BACKPACK_CAPACITY := 100

var backpack: Array = []  # Array of CatInstance
var ore_inventory: Dictionary = {}  # ore_id -> count
var active_companion: CatInstance = null
var reputation: int = 0

# Loaded ore type data for value lookups
var ore_types: Dictionary = {}  # ore_id -> OreType
var cat_species: Dictionary = {}  # species_id -> CatSpecies

func _ready() -> void:
	_load_ore_types()
	_load_cat_species()

func _load_ore_types() -> void:
	var dir := DirAccess.open("res://resources/ores/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var ore: OreType = load("res://resources/ores/" + file_name)
				if ore:
					ore_types[ore.ore_id] = ore
			file_name = dir.get_next()

func _load_cat_species() -> void:
	var dir := DirAccess.open("res://resources/cats/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var cat: CatSpecies = load("res://resources/cats/" + file_name)
				if cat:
					cat_species[cat.species_id] = cat
			file_name = dir.get_next()

func add_cat(cat_instance: CatInstance) -> bool:
	if backpack.size() >= BACKPACK_CAPACITY:
		return false
	backpack.append(cat_instance)
	return true

func set_companion(cat_instance: CatInstance) -> void:
	active_companion = cat_instance
	EventBus.companion_changed.emit(cat_instance)

func remove_companion() -> void:
	active_companion = null
	EventBus.companion_changed.emit(null)

func add_ore(ore_id: String, amount: int = 1) -> void:
	if ore_inventory.has(ore_id):
		ore_inventory[ore_id] += amount
	else:
		ore_inventory[ore_id] = amount

func get_ore_value(ore_id: String) -> int:
	if ore_types.has(ore_id):
		return ore_types[ore_id].base_value
	return 10  # default

func deliver_all_ore() -> int:
	var total_value := 0
	for ore_id in ore_inventory:
		var count: int = ore_inventory[ore_id]
		var value: int = get_ore_value(ore_id)
		total_value += count * value
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

func get_ore_type(ore_id: String) -> OreType:
	return ore_types.get(ore_id)

func get_cat_species_data(species_id: String) -> CatSpecies:
	return cat_species.get(species_id)
