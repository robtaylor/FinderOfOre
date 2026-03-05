extends Node2D

## Overworld scene - generates tile-based world programmatically.
## Uses TileMapLayer nodes for ground and collision layers.

const TILE_SIZE := 32
const WORLD_WIDTH := 30  # tiles (960px)
const WORLD_HEIGHT := 20  # tiles (640px)

# Tile source IDs
const SRC_GROUND := 0
const SRC_WALL := 1
const SRC_PATH := 2
const SRC_WATER := 3
const SRC_DARK_GRASS := 4

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var collision_layer: TileMapLayer = $CollisionLayer

func _ready() -> void:
	var tileset := _create_tileset()
	ground_layer.tile_set = tileset
	collision_layer.tile_set = tileset
	_generate_world()

func _create_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Add physics layer for collisions (layer 1 = World)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)

	# Create all sources
	_add_tile_source(tileset, SRC_GROUND, "res://assets/tilesets/ground.png", false)
	_add_tile_source(tileset, SRC_WALL, "res://assets/tilesets/wall.png", true)
	_add_tile_source(tileset, SRC_PATH, "res://assets/tilesets/path.png", false)
	_add_tile_source(tileset, SRC_WATER, "res://assets/tilesets/water.png", true)
	_add_tile_source(tileset, SRC_DARK_GRASS, "res://assets/tilesets/dark_grass.png", false)

	return tileset

func _add_tile_source(tileset: TileSet, source_id: int, texture_path: String, has_collision: bool) -> void:
	var src := TileSetAtlasSource.new()
	var tex := load(texture_path)
	if tex == null:
		# Fallback: generate a placeholder
		tex = _create_fallback_texture()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	src.create_tile(Vector2i(0, 0))
	tileset.add_source(src, source_id)

	if has_collision:
		var half := TILE_SIZE / 2.0
		var tile_data := src.get_tile_data(Vector2i(0, 0), 0)
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)
		]))

func _create_fallback_texture() -> ImageTexture:
	var img := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color.MAGENTA)
	return ImageTexture.create_from_image(img)

func _generate_world() -> void:
	# Fill ground layer with grass
	for x in range(WORLD_WIDTH):
		for y in range(WORLD_HEIGHT):
			ground_layer.set_cell(Vector2i(x, y), SRC_GROUND, Vector2i(0, 0))

	# Add some dark grass patches for variety
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(20):
		var cx := rng.randi_range(3, WORLD_WIDTH - 4)
		var cy := rng.randi_range(3, WORLD_HEIGHT - 4)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if rng.randf() > 0.3:
					ground_layer.set_cell(Vector2i(cx + dx, cy + dy), SRC_DARK_GRASS, Vector2i(0, 0))

	# Border walls
	for x in range(WORLD_WIDTH):
		collision_layer.set_cell(Vector2i(x, 0), SRC_WALL, Vector2i(0, 0))
		collision_layer.set_cell(Vector2i(x, WORLD_HEIGHT - 1), SRC_WALL, Vector2i(0, 0))
	for y in range(WORLD_HEIGHT):
		collision_layer.set_cell(Vector2i(0, y), SRC_WALL, Vector2i(0, 0))
		collision_layer.set_cell(Vector2i(WORLD_WIDTH - 1, y), SRC_WALL, Vector2i(0, 0))

	# Paths - a cross-shaped path system
	var mid_x := WORLD_WIDTH / 2
	var mid_y := WORLD_HEIGHT / 2
	for x in range(1, WORLD_WIDTH - 1):
		ground_layer.set_cell(Vector2i(x, mid_y), SRC_PATH, Vector2i(0, 0))
		ground_layer.set_cell(Vector2i(x, mid_y - 1), SRC_PATH, Vector2i(0, 0))
	for y in range(1, WORLD_HEIGHT - 1):
		ground_layer.set_cell(Vector2i(mid_x, y), SRC_PATH, Vector2i(0, 0))
		ground_layer.set_cell(Vector2i(mid_x + 1, y), SRC_PATH, Vector2i(0, 0))

	# Interior wall clusters
	_place_wall_cluster(5, 4, 3, 2)
	_place_wall_cluster(22, 6, 2, 3)
	_place_wall_cluster(8, 14, 3, 2)
	_place_wall_cluster(20, 15, 2, 2)

	# Small pond
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			collision_layer.set_cell(Vector2i(12 + dx, 5 + dy), SRC_WATER, Vector2i(0, 0))

func _place_wall_cluster(start_x: int, start_y: int, w: int, h: int) -> void:
	for dx in range(w):
		for dy in range(h):
			collision_layer.set_cell(Vector2i(start_x + dx, start_y + dy), SRC_WALL, Vector2i(0, 0))
