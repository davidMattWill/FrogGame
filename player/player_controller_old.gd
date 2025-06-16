extends CharacterBody2D

# Constants for movement
const SPEED = 120
const JUMP_VELOCITY = -500
const KNOCKBACK_SPEED = 200
const JUMP_FROM_ROLL_VELOCITY = 500 

# Gravity from project settings for consistency with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2 = Vector2.ZERO
var slide_speed = 120  # Speed of sliding down the slope

# Node references
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var ray: RayCast2D = $RayCast2D
@onready var dust_scene = preload("res://player/dust_plume.tscn")
@onready var jump_bar = $JumpBar

var anim_states = [
	"idle", "hop_ready", "hop_up", 
	"hop_down", "hop_land", 
	"ready_roll_backward", "roll_backward", 
	"ready_roll_forward", "roll_forward",
	"hit", "dead"]

var anim_conditions = [
	"fall_from_roll", "hop_apex", 
	"hop_landing", "hop_start", 
	"jump_from_roll", "player_dead", 
	"player_dead_reset", "player_hit", 
	"roll_backward", "roll_forward", "hop_released"]

# State flags
var getting_ready_to_hop: bool = false
var ready_to_hop: bool = false
var ready_to_land: bool = false
var landing: bool = false
var is_attacked: bool = false
var is_on_slope: bool = false
var jumping_from_roll: bool = false


var space_held: bool = false
var space_released: bool = false
var hold_time = 0.0
var max_hold_time = 0.5

signal health_changed(value)
var playerhealth = 3



func _ready():
	# Initialize animation tree and connect signal
	animation_tree.active = true
	animation_tree.connect("animation_finished", _on_animation_finished)
	jump_bar.visible = false

func _process(delta):
	# Update animation parameters each frame
	update_animation_parameters(delta)
	#print_flags()


func print_flags():
	print("getting ready to hop: ", getting_ready_to_hop)
	print("ready to hop: ", ready_to_hop)
	print("ready to land:", ready_to_land)
	print("landing: ", landing)
	print("is on slope: ", is_on_slope)

func _physics_process(delta):
	# Get movement input
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if space_held:
		hold_time += delta
		hold_time = min(hold_time, max_hold_time)
		jump_bar.value = (hold_time / max_hold_time) * 100
		
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Perform jump when ready
	if ready_to_hop and space_released:
		velocity.y = JUMP_VELOCITY * (hold_time / max_hold_time)
		ready_to_hop = false
		space_released = false
		_set_animation_conditions_true(['hop_released'])
	
	# Handle horizontal movement
	if direction != Vector2.ZERO and not landing and not getting_ready_to_hop and not is_attacked and not is_on_slope and not jumping_from_roll:
		velocity.x = direction.x * SPEED
	else:
		if not is_attacked and not jumping_from_roll:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	if is_on_floor() and not is_attacked and not is_on_slope:
		velocity.x = 0
		
	if is_on_floor() and is_attacked:
		var frames: Sprite2D = $player_frames
		#make player fall in correct direction with correct orientation
		if !frames.flip_h:
			velocity = Vector2(-KNOCKBACK_SPEED, -KNOCKBACK_SPEED)
		else:
			velocity = Vector2(KNOCKBACK_SPEED, -KNOCKBACK_SPEED)
	
	if is_on_slope and jumping_from_roll:
		var wall_normal = get_wall_normal()
		velocity = wall_normal.normalized() * JUMP_FROM_ROLL_VELOCITY
		animation_tree["parameters/" + "hop_up" + "/blend_position"] = wall_normal
		
	# Apply movement
	move_and_slide()

# Helper to reset and set animation conditions
func _set_animation_conditions_true(conditions: Array):
	#clear all animation conditions
	for condition in anim_conditions:
		animation_tree.set("parameters/conditions/" + condition, false)
	if conditions.is_empty():
		return
	#set passed conditions to tryue
	for condition in conditions:
		if condition in anim_conditions:
			animation_tree.set("parameters/conditions/" + condition, true)
			
# Update animation parameters and states
func update_animation_parameters(delta):
	# Update blend positions for all animations if moving and not in specific states
	if direction != Vector2.ZERO and not getting_ready_to_hop and not landing and not is_on_slope and not jumping_from_roll:
		for state in anim_states:
			animation_tree["parameters/" + state + "/blend_position"] = direction
		ray.rotation = -direction.x * 45

		# Handle slope landing
	if is_on_floor():
		var floor_normal = get_floor_normal()
		if floor_normal == Vector2.UP:
			is_on_slope = false
			jumping_from_roll = false
			if Input.is_action_just_pressed("ui_accept") and not landing and not space_held and not is_attacked:
				_set_animation_conditions_true(["hop_start"])
				getting_ready_to_hop = true
				#initiate the jump sequence
				space_held = true
				hold_time = 0.0
				jump_bar.visible = true
			
			if ready_to_land and not is_attacked:
				_set_animation_conditions_true(["hop_landing"])
				ready_to_land = false
				landing = true
				
				# Spawn dust effect
				var dust = dust_scene.instantiate()
				dust.global_position = $Marker2D.global_position
				get_parent().add_child(dust)
			
			if is_on_floor() and is_attacked:
				_set_animation_conditions_true(["player_dead"])
				is_attacked = false

	if is_on_wall_only() and velocity.y > 0:
		var wall_normal = get_wall_normal()
		var wall_angle = wall_normal.angle()
		var angle_deg = rad_to_deg(wall_angle)
		#meaning we're on a slope
		print(angle_deg)
		if (angle_deg < -40 and angle_deg > -50) or (angle_deg < -130 and angle_deg > -140):
			if not is_on_slope and jumping_from_roll:
				jumping_from_roll = false
			is_on_slope = true
			if ray.is_colliding():
				_set_animation_conditions_true(["roll_backward"])
			else:
				_set_animation_conditions_true(["roll_forward"])
		
	if Input.is_action_just_pressed("ui_accept") and is_on_slope:
		jumping_from_roll = true
		_set_animation_conditions_true(["jump_from_roll"])
			
	
	if Input.is_action_just_released("ui_accept") and space_held:
		space_held = false
		space_released = true
		jump_bar.visible = false
		
	# Handle falling and apex
	if not is_on_floor() and not is_on_wall():
		is_on_slope = false
		if not is_attacked:
			if velocity.y > 0: 
				_set_animation_conditions_true(["hop_apex", "fall_from_roll"])
			ready_to_land = true
	

func _on_animation_finished(anim: String):
	if anim in ["hop_ready_l", "hop_ready_r"]:
		getting_ready_to_hop = false
		ready_to_hop = true
	
	if anim in ["hop_land_l", "hop_land_r"]:
		landing = false


func _on_player_attacked():
	if not is_attacked:
		is_attacked = true
		var frames: Sprite2D = $player_frames
		#make player fall in correct direction with correct orientation
		if !frames.flip_h:
			animation_tree["parameters/" + "hit" + "/blend_position"] = Vector2(1,0)
			animation_tree["parameters/" + "dead" + "/blend_position"] = Vector2(1,0)
		else:
			animation_tree["parameters/" + "hit" + "/blend_position"] = Vector2(-1,0)
			animation_tree["parameters/" + "dead" + "/blend_position"] = Vector2(-1,0)
		
		playerhealth = playerhealth - 1
		emit_signal("health_changed", playerhealth)
		_set_animation_conditions_true(["player_hit"])

	
	
