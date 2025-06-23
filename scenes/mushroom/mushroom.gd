extends StaticBody2D
@onready var area = $Area2D
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var anim_conditions = [
	"mushroom_hit",
]

var is_shooting = false
var shoot_time = 0.0
var max_shoot_time = 2.0

func _ready():
	area.body_entered.connect(_on_body_entered)
	animation_tree.active = true
	
func _process(delta):
	if is_shooting:
		shoot_time += delta
	
	if shoot_time >= max_shoot_time:
		_set_animation_conditions_true([])
		is_shooting = false
		shoot_time = 0.0

func _on_body_entered(body):
	if player:
		if body == player:
			print("REE")
			#print("body", body.position)
			#print("area", area.global_position)
			var direction = (body.global_position - area.global_position).normalized()
			print(direction)
			if direction.y < 0:
				player._on_hit_mushroom()
				_set_animation_conditions_true(["mushroom_hit"])
				is_shooting = true
	
			

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
		
