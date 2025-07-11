extends Camera2D

# Reference to the player node
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")


# How quickly the camera catches up (lower = smoother, more trailing)
@export var follow_speed: float = 20

# Lower boundary for the camera (y-axis, adjust as needed)
@export var lower_bound_y: float = 1000

# Pixel size (1.0 for 1 unit = 1 pixel, adjust if using a different pixel-to-unit ratio)
@export var pixel_size: float = 1.0

func _ready():
	# Ensure the player node is valid
	if not player:
		push_error("Player node not found! Check the path to PlayerCharacter.")
		set_process(false)

func _process(delta):
	if player:
		# Get the player's position
		var target_position = player.global_position
		
		# Smoothly interpolate the camera's position
		var new_position = global_position.lerp(target_position, follow_speed * delta)
		
		# Round to the nearest pixel for pixel-perfect positioning
		new_position.x = round(new_position.x / pixel_size) * pixel_size
		new_position.y = round(new_position.y / pixel_size) * pixel_size
		
		# Enforce the lower boundary
		if new_position.y >= lower_bound_y:
			new_position.y = lower_bound_y
		
		# Apply the position
		global_position = new_position
