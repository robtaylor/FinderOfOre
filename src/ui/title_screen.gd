extends Control

## Title screen with Holly's animated logo.
## Press any key or interact to start the game.

@onready var logo: TextureRect = $VBoxContainer/CenterLogo
@onready var prompt_label: Label = $VBoxContainer/PromptLabel

var frames: Array[Texture2D] = []
var current_frame := 0
var frame_timer := 0.0
var frame_rate := 6.0  # FPS
var prompt_visible := true
var blink_timer := 0.0

func _ready() -> void:
	# Load title frames
	for i in range(5):
		var tex := load("res://assets/sprites/ui/title/frame%d.png" % i)
		if tex:
			frames.append(tex)
	if not frames.is_empty():
		logo.texture = frames[0]

func _process(delta: float) -> void:
	# Animate logo
	if not frames.is_empty():
		frame_timer += delta
		if frame_timer >= 1.0 / frame_rate:
			frame_timer = 0.0
			current_frame = (current_frame + 1) % frames.size()
			logo.texture = frames[current_frame]

	# Blink prompt
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
