extends CharacterBody2D

const SPEED := 140.0

enum State { IDLE, WALKING, CATCHING, MINING, DIALOGUE }
var current_state: State = State.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera: Camera2D = $Camera2D

var facing_direction := Vector2.DOWN
var interactable_targets: Array = []

func _ready() -> void:
	_update_interaction_area_position()

func _physics_process(_delta: float) -> void:
	if current_state in [State.CATCHING, State.MINING, State.DIALOGUE]:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		facing_direction = _snap_to_cardinal(input_dir)
		_update_interaction_area_position()
		velocity = input_dir * SPEED
		_set_state(State.WALKING)
		_update_animation()
	else:
		velocity = Vector2.ZERO
		if current_state == State.WALKING:
			_set_state(State.IDLE)
		_update_animation()

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_state in [State.IDLE, State.WALKING]:
		_try_interact()
	elif event.is_action_pressed("open_backpack") and current_state in [State.IDLE, State.WALKING]:
		EventBus.backpack_opened.emit()

func _try_interact() -> void:
	if interactable_targets.is_empty():
		return
	var target = interactable_targets[0]
	if target.has_method("interact"):
		target.interact(self)

func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	EventBus.player_state_changed.emit(State.keys()[new_state])

func _update_animation() -> void:
	if current_state == State.MINING:
		# Face the ore: pick left or right based on where the ore is
		if facing_direction == Vector2.LEFT or facing_direction == Vector2.UP:
			sprite.play("mining_left")
		else:
			sprite.play("mining_right")
		return
	var anim_prefix := "idle_" if current_state != State.WALKING else "walk_"
	if facing_direction == Vector2.DOWN:
		sprite.play(anim_prefix + "down")
	elif facing_direction == Vector2.UP:
		sprite.play(anim_prefix + "up")
	elif facing_direction == Vector2.LEFT:
		sprite.play(anim_prefix + "left")
	elif facing_direction == Vector2.RIGHT:
		sprite.play(anim_prefix + "right")

func _snap_to_cardinal(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if dir.y > 0 else Vector2.UP

func _update_interaction_area_position() -> void:
	if interaction_area:
		interaction_area.position = facing_direction * 24.0

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("interact"):
		interactable_targets.append(body)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	interactable_targets.erase(body)

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.has_method("interact"):
		interactable_targets.append(area)
	elif area.get_parent().has_method("interact"):
		interactable_targets.append(area.get_parent())

func _on_interaction_area_area_exited(area: Area2D) -> void:
	interactable_targets.erase(area)
	if area.get_parent() in interactable_targets:
		interactable_targets.erase(area.get_parent())

func set_player_state(state: State) -> void:
	_set_state(state)
	_update_animation()
