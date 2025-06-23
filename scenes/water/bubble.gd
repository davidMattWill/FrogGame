extends Node2D

@export var speed: float = 50.0  # Upward speed
@export var wobble_amplitude: float = 10.0  # Side-to-side wobble
@export var wobble_frequency: float = 2.0  # Wobble speed
@export var lifetime: float = 3.0  # Seconds before bubble disappears

var time: float = 0.0

func _ready():
	# Start a timer to despawn the bubble
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	# Move upward
	position.y -= speed * delta
	# Add side-to-side wobble
	time += delta
	position.x += sin(time * wobble_frequency) * wobble_amplitude * delta
