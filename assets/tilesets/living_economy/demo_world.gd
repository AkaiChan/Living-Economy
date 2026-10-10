extends Node2D
## Living Economy tile kit demonstration for Godot 4.3+
## Attach to an empty Node2D, or run demo_world.tscn.

const TERRAIN = preload("res://assets/tilesets/living_economy/terrain_tileset.tres")
const OBJECTS = preload("res://assets/tilesets/living_economy/assets/objects_atlas_128x160.png")
const MAP_SIZE := 12

func _ready() -> void:
	var ground := TileMapLayer.new()
	ground.name = "Ground_TileMapLayer"
	ground.tile_set = TERRAIN
	add_child(ground)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261010
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			var kind := 0
			if x < 3 and y > 7: kind = 5 # sand
			elif x > 9 and y > 6: kind = 9 # water
			elif x == 5 or y == 5: kind = 4 # road
			elif rng.randf() < 0.16: kind = 1 # meadow
			ground.set_cell(Vector2i(x, y), 0, Vector2i(kind % 4, int(kind / 4)))
	# Decoration sprites: deliberately separate from terrain TileMapLayer.
	for point in [Vector2i(1,1), Vector2i(2,3), Vector2i(8,1), Vector2i(9,3)]:
		_place_object(ground.map_to_local(point), 0)
	_place_object(ground.map_to_local(Vector2i(4,4)), 5) # carpenter
	_place_object(ground.map_to_local(Vector2i(7,4)), 6) # inn
	_place_object(ground.map_to_local(Vector2i(3,8)), 8) # stall

func _place_object(at: Vector2, index: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = OBJECTS
	sprite.region_enabled = true
	sprite.region_rect = Rect2((index % 4) * 128, int(index / 4) * 160, 128, 160)
	sprite.position = at + Vector2(0, -55)
	sprite.z_index = 1
	add_child(sprite)
