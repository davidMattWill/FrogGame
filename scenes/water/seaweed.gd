extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

func _ready():
	# Connect the timer's timeout signal to a function
	timer.timeout.connect(_on_timer_timeout)
	# Start the timer with a random initial wait time
	start_timer_with_random_interval()

func start_timer_with_random_interval():
	# Set a random wait time (e.g., between 2 and 10 seconds)
	var random_wait = randf_range(2.0, 10.0)
	timer.wait_time = random_wait
	timer.start()

func _on_timer_timeout():
	# Play the animation
	animation_player.play("sway_weak")
	# Restart the timer with a new random interval
	start_timer_with_random_interval()
