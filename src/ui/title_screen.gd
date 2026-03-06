extends Control

## Title screen with Holly's animated logo.
## Press any key or interact to start the game.

@onready var logo: AnimatedSprite2D = $CenterContainer/Logo
@onready var prompt_label: Label = $PromptLabel

var prompt_visible := true
var blink_timer := 0.0

func _ready() -> void:
	logo.play("idle")

func _process(delta: float) -> void:
	# Blink the "press any key" prompt
	blink_timer += delta
	if blink_timer >= 0.6:
		blink_timer = 0.0
		prompt_visible = not prompt_visible
		prompt_label.visible = prompt_visible

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_start_game()
	elif event is InputEventMouseButton and event.pressed:
		_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
