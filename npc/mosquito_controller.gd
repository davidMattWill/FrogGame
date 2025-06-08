extends CharacterBody2D

# Adjustable parameters
@export var base_radius: float = 30.0      # Base radius of the subtle circular motion
@export var attack_radius: float = 100
@export var attack_speed: float = 200
@export var speed: float = 2.0            # Speed of circling (radians per second)
@export var radius_variation: float = 10.0 # How much the radius wobbles
@export var variation_speed: float = 1.5   # Speed of radius variation
@export var max_speed: float = 200.0      # Max movement speed for base motion
@export var zip_speed: float = 300.0      # Speed of random zips
@export var zip_chance: float = 0.02      # Chance per frame of a zip (0.0 to 1.0)
@export var zip_duration: float = 0.2     # How long a zip lasts (seconds)
@export var zip_cooldown: float = 0.5     # Min time between zips (seconds)

# Internal variables
var time: float = 0.0          # Tracks time for sine/cosine
var center: Vector2            # The central point to loosely circle around
var zip_timer: float = 0.0     # Tracks duration of a zip
var zip_cooldown_timer: float = 0.0  # Tracks cooldown between zips
var zip_velocity: Vector2 = Vector2.ZERO  # Velocity during a zip

var spotted_timer: float = 0.0
var max_spotted_time: float = 0.1
var attack_vector: Vector2 = Vector2.ZERO
var attacking: bool = false
var stop_threshold = 10

var attack_time: float = 0.0
var max_attack_time: float = 5.0

var collision_threshold = 2.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var animation_conditions = ["spotted_player", "attack_initiated", "reset_idle"]
var animation_states = ["idle", "wait", "attack"]

# Get the player character, we'll need this for distance calculation
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")

func _ready():
	animation_tree.active = true
	center = position

func _process(delta):
	# Animation direction
	for state in animation_states:
		if velocity.x > 0:
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(1, 0)
		else:  # Fixed the duplicate condition
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(-1, 0)
	
	if player:
		# Check for collision with player
		var distance = position.distance_to(player.position)
		if distance <= collision_threshold:
			print("COLLIDING")
			player._on_player_attacked()
		# Check for attack state
		if distance <= attack_radius and not attacking:
			attacking = true
			set_animation_condition("spotted_player", animation_conditions)
			attack_vector = (player.position - self.position).normalized()
			spotted_timer = 0.0
			attack_time = 0.0
			
	if attacking:
		spotted_timer += delta
		attack_time += delta
		
		if spotted_timer > max_spotted_time:
			set_animation_condition("attack_initiated", animation_conditions)
		if attack_time >= max_attack_time:
			attacking = false
			attack_vector = Vector2.ZERO
			set_animation_condition("reset_idle", animation_conditions)

func _physics_process(delta):
	if attacking:
		# Attack movement
		if spotted_timer <= max_spotted_time:
			velocity = Vector2.ZERO
		else:
			# Recalculate attack vector if out of bounds
			var attack_distance = position.distance_to(player.position)
			if attack_distance >= attack_radius:
				attack_vector = (player.position - self.position).normalized()
			velocity = attack_vector * attack_speed
	else:
		# Base movement logic
		time += delta
		
		# Update timers
		zip_timer -= delta
		zip_cooldown_timer -= delta
		
		# Check for a random zip
		if zip_timer <= 0.0 and zip_cooldown_timer <= 0.0 and randf() < zip_chance:
			var zip_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			zip_velocity = zip_direction * zip_speed
			zip_timer = zip_duration
			zip_cooldown_timer = zip_cooldown
		
		# Calculate velocity
		if zip_timer > 0.0:
			# During a zip, use the zip velocity
			velocity = zip_velocity
		else:
			# Base motion: subtle circular pattern with wobble
			var current_radius = base_radius + radius_variation * sin(time * variation_speed)
			var new_x = center.x + current_radius * cos(time * speed)
			var new_y = center.y + current_radius * sin(time * speed)
			var target_position = Vector2(new_x, new_y)
			velocity = (target_position - position) / delta
			
			# Limit the base velocity
			if velocity.length() > max_speed:
				velocity = velocity.normalized() * max_speed
			
			# Add a small random jitter for erratic feel
			velocity += Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
		
		# Optional: Slightly shift the center over time for a wandering effect
		center += Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0)) * delta
	
	# Set the CharacterBody2D velocity and move
	self.velocity = velocity
	move_and_slide()

func set_animation_condition(active_condition: String, conditions):
	if not animation_tree:
		print("Warning: AnimationTree not set!")
		return
	# Loop through all conditions
	for condition in conditions:
		animation_tree.set("parameters/conditions/" + condition, false)
	if active_condition in conditions:
		animation_tree.set("parameters/conditions/" + active_condition, true)
