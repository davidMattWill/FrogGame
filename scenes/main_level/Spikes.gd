extends TileMap
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
func _ready():

	# Create Area2D if not already added in editor
	var area = Area2D.new()
	area.name = "CollisionArea"
	add_child(area)
	area.collision_layer = 4  # Layer 1
	area.collision_mask = 2  # Detects layer 2 (player)

	# Get used cells in layer 0 (adjust if using different layer)
	var used_cells = get_used_cells(0)
	for cell in used_cells:
		# Get tile data
		var tile_data = get_cell_tile_data(0, cell)
		if tile_data:
			# Check if tile has physics layer
			var physics_layer = tile_data.get_collision_polygons_count(0)
			if physics_layer > 0:
				# Create CollisionShape2D for each tile
				var collision_shape = CollisionShape2D.new()
				# Use a rectangle shape (adjust based on your tile shapes)
				var shape = RectangleShape2D.new()
				shape.size = Vector2(16, 16)  # Adjust to your tile size (e.g., 16x16 pixels)
				collision_shape.shape = shape
				# Position shape at tile center
				collision_shape.position = map_to_local(cell) + Vector2(8, 8)  # Offset for center
				area.add_child(collision_shape)

	# Connect Area2D signal
	area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body):
	# Check if the colliding body is the player
	if player:
		if body == player:
			print("Spike collided with player")
			player._on_player_attacked()
		

