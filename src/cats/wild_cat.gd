extends Area2D

## A wild cat in the overworld that the player can encounter and catch.
## Shows an exclamation mark when the player is nearby.

@export var species: CatSpecies

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exclamation: Sprite2D = $Exclamation
@onready var wander_timer: Timer = $WanderTimer

var player_nearby := false
var wander_direction := Vector2.ZERO
var wander_speed := 30.0
var facing_right := true

func _ready() -> void:
	exclamation.visible = false
	_pick_new_wander_direction()

func _physics_process(delta: float) -> void:
	if player_nearby:
		return  # Stop wandering when player is near
	position += wander_direction * wander_speed * delta

func _pick_new_wander_direction() -> void:
	var rng := RandomNumberGenerator.new()
	var angle := rng.randf() * TAU
	wander_direction = Vector2(cos(angle), sin(angle))

	# Update facing direction based on movement
	if wander_direction.x > 0.1:
		facing_right = true
		anim_sprite.play("walk_right")
	elif wander_direction.x < -0.1:
		facing_right = false
		anim_sprite.play("walk_left")
	else:
		# Mostly vertical movement, keep current facing
		anim_sprite.play("walk_right" if facing_right else "walk_left")

	wander_timer.wait_time = randf_range(1.5, 4.0)
	if is_inside_tree():
		wander_timer.start()

func interact(player: Node) -> void:
	if not species:
		push_warning("WildCat has no species assigned!")
		return
	EventBus.cat_catch_started.emit(self)
	player.set_player_state(player.State.CATCHING)

func catch_succeeded() -> void:
	var cat_instance := CatInstance.new(species)
	if GameState.add_cat(cat_instance):
		EventBus.cat_catch_succeeded.emit(self)
		queue_free()
	else:
		# Backpack full
		EventBus.cat_catch_failed.emit(self)

func catch_failed() -> void:
	EventBus.cat_catch_failed.emit(self)
	# Cat runs away briefly
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		wander_direction = (global_position - player_node.global_position).normalized()
		if wander_direction.x >= 0:
			facing_right = true
			anim_sprite.play("walk_right")
		else:
			facing_right = false
			anim_sprite.play("walk_left")
	wander_speed = 80.0
	player_nearby = false
	exclamation.visible = false
	await get_tree().create_timer(1.0).timeout
	wander_speed = 30.0
	_pick_new_wander_direction()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		exclamation.visible = true
		wander_direction = Vector2.ZERO
		# Play idle animation facing the player
		var player_dir := body.global_position.x - global_position.x
		if player_dir >= 0:
			facing_right = true
			anim_sprite.play("idle_right")
		else:
			facing_right = false
			anim_sprite.play("idle_left")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		exclamation.visible = false
		_pick_new_wander_direction()

func _on_wander_timer_timeout() -> void:
	_pick_new_wander_direction()
