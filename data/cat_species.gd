class_name CatSpecies
extends Resource

@export var species_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var detectable_ores: Array[String] = []
@export var detection_radius: float = 80.0
@export var catch_difficulty: float = 0.5  # 0.0 = easy, 1.0 = hard
@export var rarity: float = 1.0  # Higher = rarer
@export var native_biomes: Array[String] = []
