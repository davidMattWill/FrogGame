extends Node2D

@export var speed_y: float = 50.0  # Upward speed
var speed_x: float = randi_range(-10, 10)

@export var wobble_amplitude: float = 10.0  # Side-to-side wobble
@export var wobble_frequency: float = 2.0  # Wobble speed
@export var lifetime: float = randi_range(3, 10)  # Seconds before bubble disappears

var time: float = 0.0

func _ready():
	# Start a timer to despawn the bubble at max lifetime (fallback)
	
	await get_tree().create_timer(lifetime).timeout
	#speed_x = randi_range(-100, 100)
	queue_free()

func _process(delta):
	# Update time
	time += delta
	
	# Calculate deletion probability (linear: 0 at t=0, 1 at t=lifetime)
	var deletion_probability = (time / lifetime) * 0.01
	# Clamp probability to [0, 1] in case time exceeds lifetime
	deletion_probability = clamp(deletion_probability, 0.0, 1.0)
	
	# Randomly delete bubble based on probability
	if randf() < deletion_probability:
		queue_free()
		return  # Exit _process to avoid further updates
	
	# Move upward
	position.y -= speed_y * delta
	position.x += speed_x * delta
	# Add side-to-side wobble
	position.x += sin(time * wobble_frequency) * wobble_amplitude * delta
