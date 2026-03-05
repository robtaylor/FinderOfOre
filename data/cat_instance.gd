class_name CatInstance
extends RefCounted

var instance_id: int
var species: CatSpecies
var nickname: String = ""
var caught_timestamp: int = 0
var total_ores_found: int = 0

static var _next_id: int = 1

func _init(cat_species: CatSpecies = null, custom_nickname: String = "") -> void:
	instance_id = _next_id
	_next_id += 1
	species = cat_species
	if custom_nickname != "":
		nickname = custom_nickname
	elif cat_species:
		nickname = cat_species.display_name
	caught_timestamp = int(Time.get_unix_time_from_system())

func get_display_name() -> String:
	return nickname if nickname != "" else species.display_name

func get_detectable_ores() -> Array[String]:
	if species:
		return species.detectable_ores
	return []

func get_detection_radius() -> float:
	if species:
		return species.detection_radius
	return 80.0
