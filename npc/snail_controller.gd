extends CharacterBody2D

# Movement properties
var speed = 3.5  # Speed of the snail
var attack_speed = 20
var direction = 1.0  # 1 for right, -1 for left
var wait_time = 0.0  # Timer for random idling
var max_wait_time = 2 # Max time to idle in seconds
var is_waiting = false
var is_attacking = false
var collision_threshold = 15
var spotted_threshold = 100

var animation_conditions = []
var animation_states  = ["idle", "attack"]
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
	#if the snail hits an edge we flip direction
	if !floorcast_left.is_colliding() or !floorcast_right.is_colliding() or wallcast_left.is_colliding() or wallcast_right.is_colliding():
		direction *= -1
	
	#if we spot the player we start attacking in the players direction
	
		
	# Handle idling behavior
	if is_waiting:
		velocity.x = 0
		wait_time -= delta
		if wait_time <= 0:
			is_waiting = false
			direction = 1.0 if randf() > 0.5 else -1.0  # Randomly choose new direction
	if is_attacking:
		velocity.x = attack_speed * direction
	
	if not is_waiting and not is_attacking:
		# Move the snail
		velocity.x = direction * speed
		
		# Randomly decide to idle
		if randf() < 0.001:  # 1% chance per frame to idle
			is_waiting = true
			wait_time = randf_range(0.5, max_wait_time)
			velocity.x = 0  # Stop moving while idling
	move_and_slide()
	

func _process(delta):
	if player:
		# Check for collision with player
		var distance = position.distance_to(player.position)
		if distance <= collision_threshold:
			print("COLLIDING")
			player._on_player_attacked(self.position - player.position)
		
		var distance_vector = player.position - self.position
		if distance > collision_threshold and distance < spotted_threshold and (distance_vector.x < 0 and direction < 0 ) or (distance_vector.x > 0 and direction > 0):
			is_attacking = true
			animation_tree.set("parameters/conditions/" + "spotted_player", true)
			animation_tree.set("parameters/conditions/" + "lost_player", false)
		else:
			is_attacking = false
			animation_tree.set("parameters/conditions/" + "spotted_player", false)
			animation_tree.set("parameters/conditions/" + "lost_player", true)
			
		
		
			
	
	#change blendstate for animation direction
	for state in animation_states:
		if velocity.x > 0:
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(1, 0)
		else:  # Fixed the duplicate condition
			animation_tree["parameters/" + state + "/blend_position"] = Vector2(-1, 0)


