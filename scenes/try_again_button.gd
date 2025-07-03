extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure the node can receive input events
	set_process_input(true)
	mouse_filter = MOUSE_FILTER_STOP  # Makes the sprite intercept mouse events

# Called when an input event occurs on this node
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Play the "click" animation when left mouse button is pressed
		play("click")

# Optional: If you want to ensure the animation plays only when clicking within the sprite's area
func _process(delta):
	pass  # No need for _process in this case, but you can keep it for other logic
