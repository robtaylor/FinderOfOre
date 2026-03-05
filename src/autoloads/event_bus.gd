extends Node

# Cat signals
signal cat_encountered(wild_cat: Node)
signal cat_catch_started(wild_cat: Node)
signal cat_catch_succeeded(wild_cat: Node)
signal cat_catch_failed(wild_cat: Node)
signal companion_changed(cat_instance)

# Ore signals
signal ore_detected(ore_node: Node)
signal ore_mining_started(ore_node: Node)
signal ore_mining_completed(ore_node: Node, ore_type)
signal ore_delivered(ore_type, amount: int)

# Player signals
signal player_state_changed(new_state: String)

# NPC signals
signal dialogue_started(npc: Node)
signal dialogue_ended(npc: Node)

# UI signals
signal backpack_opened()
signal backpack_closed()

# Game signals
signal reputation_changed(new_value: int)
signal biome_entered(biome_data)
