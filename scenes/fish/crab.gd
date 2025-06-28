extends Node2D

var direction = 1.0
var speed = 5

@export var bubble_scene: PackedScene

@onready var ray_left: RayCast2D = $ray_left
@onready var ray_right: RayCast2D = $ray_right
@onready var ray_down_left: RayCast2D = $ray_down_left
@onready var ray_down_right: RayCast2D = $ray_down_right

@onready var crab_frames: Sprite2D = $crab_frames

@onready var animation_tree: AnimationTree = $AnimationTree


func _ready():
	# set a random direction for the fish to idle
	direction = 1.0 if randf() > 0.5 else -1.0
	animation_tree.active = true
	animation_tree["parameters/" + "idle" + "/blend_position"] = Vector2(direction, 0)
	



func _process(delta):
	if ray_left.is_colliding() or ray_right.is_colliding():
		direction *= -1
	if !ray_down_left.is_colliding() or !ray_down_right.is_colliding():
		direction *= -1
	if randf() < 0.001:  # 1% chance per frame to idle
		direction *= -1
	animation_tree["parameters/" + "idle" + "/blend_position"] =  Vector2(direction, 0)
	
	var velocity= direction * speed
	position.x += velocity * delta
	
	
