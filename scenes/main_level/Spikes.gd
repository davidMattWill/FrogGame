extends TileMap

@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")

func _ready():
	# Create Area2D if not already added in editor
	var area = Area2D.new()
	area.name = "CollisionArea"
	add_child(area)
	area.collision_layer = self.tile_set.get_physics_layer_collision_layer(0) # Layer 1
	area.collision_mask = self.tile_set.get_physics_layer_collision_mask(0)  # Detects layer 2 (player)

	# Get used cells in layer 0 (adjust if using different layer)
	var used_cells = get_used_cells(0)
	for cell in used_cells:
		# Get tile data
		var tile_data = get_cell_tile_data(0, cell)
		if tile_data:
			# Check if tile has physics layer
			var physics_layer_count = tile_data.get_collision_polygons_count(0)
			if physics_layer_count > 0:
				for i in range(physics_layer_count):
					var collision_shape = CollisionShape2D.new()
					var polygon_points = tile_data.get_collision_polygon_points(0, i)
					if polygon_points.size() > 0:
						var shape = ConvexPolygonShape2D.new()
						shape.points = polygon_points
						collision_shape.shape = shape
						collision_shape.position = map_to_local(cell)
						# Store the tile's position as metadata
						collision_shape.set_meta("tile_position", map_to_local(cell))
						area.add_child(collision_shape)
					else:
						print("could not generate collision data for tile")


	# Connect Area2D signal
	area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body):
	# Check if the colliding body is the player
	if player:
		if body == player:
			print("Spike collided with player")
			player._on_player_attacked()

