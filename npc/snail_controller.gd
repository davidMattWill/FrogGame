extends CharacterBody2D

# Movement properties
var speed = 10.0  # Speed of the snail
var direction = 1.0  # 1 for right, -1 for left
var idle_time = 0.0  # Timer for random idling
var max_idle_duration = 2 # Max time to idle in seconds
var is_idling = false
var collision_threshold = 15

var animation_conditions = []
var animation_states  = ["idle"]
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
# Node references
@onready var wallcast_left: RayCast2D = $wallcast_left
@onready var wallcast_right: RayCast2D = $wallcast_right
@onready var floorcast_left: RayCast2D = $floorcast_left
@onready var floorcast_right:RayCast2D = $floorcast_right


@onready var collision_shape = $CollisionShape2D  # Reference to your collision shape
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")


func _ready():
	animation_tree.active = true
	# Randomize initial direction
	direction = 1.0 if randf() > 0.5 else -1.0
	# Ensure RayCast2D is set up (you'll need to add this node in the editor)
	var rays = [$wallcast_left, $wallcast_right, $floorcast_left, $floorcast_right]

func _physics_process(delta):

	if !floorcast_left.is_colliding() or !floorcast_right.is_colliding() or wallcast_left.is_colliding() or wallcast_right.is_colliding():
		direction *= -1
		
		
	# Handle idling behavior
	if is_idling:
		idle_time -= delta
		if idle_time <= 0:
			is_idling = false
			direction = 1.0 if randf() > 0.5 else -1.0  # Randomly choose new direction
	else:
		# Move the snail
		velocity.x = direction * speed
		move_and_slide()
		
		# Randomly decide to idle
		if randf() < 0.001:  # 1% chance per frame to idle
			is_idling = true
			idle_time = randf_range(0.5, max_idle_duration)
			velocity.x = 0  # Stop moving while idling

func _process(delta):
	
	if player:
		# Check for collision with player
		var distance = position.distance_to(player.position)
		if distance <= collision_threshold:
			print("COLLIDING")
			player._on_player_attacked()
	
	
	for state in animation_states:
		if velocity.x > 0:
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(1, 0)
		else:  # Fixed the duplicate condition
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(-1, 0)


