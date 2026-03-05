extends Node2D

## Overworld scene - generates tile-based world programmatically.
## Uses TileMapLayer nodes for ground and collision layers.

const TILE_SIZE := 16
const WORLD_WIDTH := 60  # tiles
const WORLD_HEIGHT := 40  # tiles

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
	_add_tile_source(tileset, SRC_GROUND, Color(0.3, 0.6, 0.2), false)
	_add_tile_source(tileset, SRC_WALL, Color(0.35, 0.3, 0.25), true, Color(0.2, 0.18, 0.15))
	_add_tile_source(tileset, SRC_PATH, Color(0.7, 0.6, 0.4), false)
	_add_tile_source(tileset, SRC_WATER, Color(0.2, 0.4, 0.8), true)
	_add_tile_source(tileset, SRC_DARK_GRASS, Color(0.25, 0.5, 0.18), false)

	return tileset

func _add_tile_source(tileset: TileSet, source_id: int, fill_color: Color, has_collision: bool, border_color: Color = Color.TRANSPARENT) -> void:
	var src := TileSetAtlasSource.new()
	src.texture = _create_tile_texture(fill_color, border_color)
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	src.create_tile(Vector2i(0, 0))
	tileset.add_source(src, source_id)

	if has_collision:
		var tile_data := src.get_tile_data(Vector2i(0, 0), 0)
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)
		]))

func _create_tile_texture(fill_color: Color, border_color: Color = Color.TRANSPARENT) -> ImageTexture:
	var img := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(fill_color)
	if border_color.a > 0:
		for x in range(TILE_SIZE):
			img.set_pixel(x, 0, border_color)
			img.set_pixel(x, TILE_SIZE - 1, border_color)
		for y in range(TILE_SIZE):
			img.set_pixel(0, y, border_color)
			img.set_pixel(TILE_SIZE - 1, y, border_color)
	return ImageTexture.create_from_image(img)

func _generate_world() -> void:
	# Fill ground layer with grass
	for x in range(WORLD_WIDTH):
		for y in range(WORLD_HEIGHT):
			ground_layer.set_cell(Vector2i(x, y), SRC_GROUND, Vector2i(0, 0))

	# Add some dark grass patches for variety
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(40):
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
	_place_wall_cluster(10, 8, 4, 3)
	_place_wall_cluster(45, 12, 3, 4)
	_place_wall_cluster(15, 28, 5, 2)
	_place_wall_cluster(40, 30, 3, 3)

	# Small pond
	for dx in range(-2, 3):
		for dy in range(-1, 2):
			collision_layer.set_cell(Vector2i(25 + dx, 10 + dy), SRC_WATER, Vector2i(0, 0))

func _place_wall_cluster(start_x: int, start_y: int, w: int, h: int) -> void:
	for dx in range(w):
		for dy in range(h):
			collision_layer.set_cell(Vector2i(start_x + dx, start_y + dy), SRC_WALL, Vector2i(0, 0))
