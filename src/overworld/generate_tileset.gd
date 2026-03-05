@tool
extends EditorScript

## Run this in the Godot editor (Script > Run) to generate placeholder tileset images.
## Creates 16x16 colored squares for ground and wall tiles.

func _run() -> void:
	# Ground tile - green
	var ground := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	ground.fill(Color(0.3, 0.6, 0.2, 1.0))
	ground.save_png("res://assets/tilesets/ground.png")

	# Wall tile - dark gray
	var wall := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	wall.fill(Color(0.35, 0.3, 0.25, 1.0))
	# Add border for visibility
	for x in range(16):
		wall.set_pixel(x, 0, Color(0.2, 0.18, 0.15))
		wall.set_pixel(x, 15, Color(0.2, 0.18, 0.15))
	for y in range(16):
		wall.set_pixel(0, y, Color(0.2, 0.18, 0.15))
		wall.set_pixel(15, y, Color(0.2, 0.18, 0.15))
	wall.save_png("res://assets/tilesets/wall.png")

	# Path tile - sandy
	var path := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	path.fill(Color(0.7, 0.6, 0.4, 1.0))
	path.save_png("res://assets/tilesets/path.png")

	# Water tile - blue
	var water := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	water.fill(Color(0.2, 0.4, 0.8, 1.0))
	water.save_png("res://assets/tilesets/water.png")

	print("Tileset images generated!")
