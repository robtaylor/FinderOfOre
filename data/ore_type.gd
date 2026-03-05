class_name OreType
extends Resource

@export var ore_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var color: Color = Color.GRAY
@export var base_value: int = 10
@export var mine_time: float = 2.0  # seconds
@export var found_in_biomes: Array[String] = []
@export var spawn_weight: float = 1.0  # Higher = more common
