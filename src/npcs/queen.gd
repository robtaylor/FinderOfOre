extends StaticBody2D

## The Queen NPC. Deliver ore to her to earn reputation.

@onready var sprite: ColorRect = $Sprite
@onready var crown: ColorRect = $Crown

func interact(player: Node) -> void:
	player.set_player_state(player.State.DIALOGUE)

	var total_ore := GameState.get_total_ore_count()
	if total_ore == 0:
		EventBus.dialogue_started.emit(self)
		_show_dialogue([
			"Queen: Welcome, Miku!",
			"Queen: Bring me ore from the mines and I shall reward you handsomely.",
			"Queen: Use your cats to sniff out the deposits!",
		], player)
	else:
		var value := GameState.deliver_all_ore()
		EventBus.dialogue_started.emit(self)
		_show_dialogue([
			"Queen: Splendid work, Miku!",
			"Queen: I'll take all that ore off your hands.",
			"Queen: That's worth %d reputation points!" % value,
			"Queen: Your total reputation is now %d." % GameState.reputation,
			"Queen: Keep exploring and bring me more!",
		], player)

func _show_dialogue(lines: Array[String], player: Node) -> void:
	var dialogue_ui := get_tree().get_first_node_in_group("dialogue_ui")
	if dialogue_ui:
		dialogue_ui.show_dialogue(lines)
		await dialogue_ui.dialogue_finished
	player.set_player_state(player.State.IDLE)
	EventBus.dialogue_ended.emit(self)
