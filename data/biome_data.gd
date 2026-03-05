class_name BiomeData
extends Resource

@export var biome_id: String = ""
@export var display_name: String = ""
@export var ground_color: Color = Color(0.3, 0.6, 0.2)
@export var spawnable_cats: Array[CatSpecies] = []
@export var available_ores: Array[OreType] = []
@export var encounter_rate: float = 0.1  # Chance per step of cat encounter
@export var ore_density: float = 1.0  # Multiplier for ore spawn count
