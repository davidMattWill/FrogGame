extends CharacterBody2D

# Constants for movement
const SPEED = 120
const JUMP_VELOCITY = -500
const KNOCKBACK_SPEED = 200
const JUMP_FROM_ROLL_VELOCITY = 450

# Gravity from project settings for consistency with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2 = Vector2.ZERO

# Node references
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var ray: RayCast2D = $RayCast2D
@onready var dust_scene = preload("res://player/dust_plume.tscn")
@onready var jump_bar = $JumpBar

var current_state: String = ""
var anim_states = [
	"idle", "hop_ready", "hop_up", 
	"hop_down", "hop_land", 
	"ready_roll_backward", "roll_backward", 
	"ready_roll_forward", "roll_forward",
	"hit", "dead"]

var anim_conditions = [
	"fall_from_roll",
	"hop_apex",
	"hop_landing",
	"hop_released",
	"hop_cancelled",
	"hop_start",
	"jump_from_roll",
	"player_dead",
	"player_dead_reset",
	"player_hit",
	"roll_backward",
	"roll_forward",
	"hop_released",
	"hit_mushroom"
]

var space_held: bool = false
var space_released: bool = false
var allowed_to_hop: bool = false
var time_spacebar_held = 0.0
var max_hold_time = 0.5

var is_on_slope: bool = false
var jumping_from_roll: bool = false



signal health_changed(value)
var playerhealth = 3

func _ready():
	# Initialize animation tree and connect signal
	animation_tree.active = true
	animation_tree.connect("animation_finished", _on_animation_finished)
	jump_bar.visible = false

func _process(delta):
	# Update animation parameters each frame
	current_state = state_machine.get_current_node()
	#if conditions are met, we can change the sprites direction. Must be in one of the following states
	if direction != Vector2.ZERO and (current_state == "idle" or current_state ==  "hop_ready" or current_state == "hop_up" or current_state == "hop_down") and not jumping_from_roll:
		for state in anim_states:
			animation_tree["parameters/" + state + "/blend_position"] = direction
		ray.rotation = -direction.x * 45
	#init the hop landing sqeuence
	if is_on_floor():
		if current_state == "hit":
			_set_animation_conditions_true(["player_dead"])
		if current_state == "hop_down" or current_state == "hop_up" or current_state == "roll_forward" or current_state == "roll_backward":
			_set_animation_conditions_true(["hop_landing"])
		if current_state == "hop_land" and animation_tree.get("parameters/conditions/" + "hop_landing"):
			_set_animation_conditions_true([])
			var dust = dust_scene.instantiate()
			dust.global_position = $Marker2D.global_position
			get_parent().add_child(dust)
	if not is_on_floor() and not is_on_slope:
		if current_state != "hit":
			if velocity.y >= 0: 
				_set_animation_conditions_true(["hop_apex", "fall_from_roll"])
			else:
				_set_animation_conditions_true(["hop_released", "jump_from_roll"])

	if is_on_wall():
		var wall_normal = get_wall_normal()
		var wall_angle = wall_normal.angle()
		var angle_deg = rad_to_deg(wall_angle)
		#meaning we're on a slope
		if (angle_deg < -40 and angle_deg > -50) or (angle_deg < -130 and angle_deg > -140):
			is_on_slope = true
			if ray.is_colliding():
				_set_animation_conditions_true(["roll_backward"])
			else:
				_set_animation_conditions_true(["roll_forward"])
		else:
			is_on_slope = false
	else:
		is_on_slope = false

func _physics_process(delta):
	#apply gravity whenever not on floor
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor():
		velocity.x = 0
		jumping_from_roll = false
	#get user input for direction
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if direction != Vector2.ZERO and not is_on_floor() and not is_on_slope and not jumping_from_roll:
		velocity.x = direction.x * SPEED
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	#if spacebar is not already being held we can allow input
	if Input.is_action_just_pressed("ui_accept") and not space_held:
		#set the condition true for going into hop_ready state
		_set_animation_conditions_true(["hop_start"])
		#activate the jump bar
		space_held = true
		space_released = false
		time_spacebar_held = 0.0
		if is_on_floor() and (current_state != "hit" and current_state != "dead"):
			jump_bar.visible = true
	#update delta for time held
	if space_held:
		time_spacebar_held += delta
		time_spacebar_held = min(time_spacebar_held, max_hold_time)
		jump_bar.value = (time_spacebar_held / max_hold_time) * 100
			
	if Input.is_action_just_released("ui_accept") and space_held:
		space_held = false
		space_released = true
		jump_bar.visible = false
		
		if not allowed_to_hop:
			_set_animation_conditions_true(["hop_cancelled"])
		else:
			if is_on_floor():
				velocity.y = JUMP_VELOCITY * (time_spacebar_held / max_hold_time)
				space_released = false
				allowed_to_hop = false
		if is_on_slope:
			var wall_normal = get_wall_normal()
			velocity = wall_normal.normalized() * JUMP_FROM_ROLL_VELOCITY
			animation_tree["parameters/" + "hop_up" + "/blend_position"] = wall_normal
			animation_tree["parameters/" + "hop_down" + "/blend_position"] = wall_normal
			jumping_from_roll = true

	move_and_slide()

#update the animation conditions in the state machine
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

func _on_player_attacked(attack_vector):
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
	
	var attack_dir = -attack_vector.x / abs(attack_vector.x)
	velocity = Vector2(attack_dir * KNOCKBACK_SPEED, -KNOCKBACK_SPEED)
	
func _on_hit_mushroom():
	print(current_state)
	_set_animation_conditions_true(["hit_mushroom"])
	velocity.y = JUMP_VELOCITY * 1.5
	
func _on_animation_finished(anim: String):
	if anim in ["hop_ready_l", "hop_ready_r"]:
		allowed_to_hop = true
	



	
	
