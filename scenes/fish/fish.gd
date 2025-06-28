extends Node2D

var direction = 1.0
var speed = 5

@export var bubble_scene: PackedScene

@onready var ray_left: RayCast2D = $ray_left
@onready var ray_right: RayCast2D = $ray_right
@onready var fish_frames: Sprite2D = $fish_frames

@onready var marker: Marker2D = $fish_frames/Marker2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	# set a random direction for the fish to idle
	direction = 1.0 if randf() > 0.5 else -1.0
	animation_tree["parameters/" + "idle" + "/blend_position"] = direction

func _process(delta):
	if ray_left.is_colliding() or ray_right.is_colliding():
		direction *= -1
	if randf() < 0.001:  # 1% chance per frame to idle
		direction *= -1
	if randf() < 0.005:  # 0.05% chance per frame to spawn a bubble
		spawn_bubble()
	animation_tree["parameters/" + "idle" + "/blend_position"] = direction

	var velocity= direction * speed
	position.x += velocity * delta
		

func spawn_bubble():
	var bubble = bubble_scene.instantiate()
	#set the bubbles position to the marker
	bubble.global_position = marker.global_position
	var bubble_sprite = bubble.get_node("bubble_frames") as Sprite2D
	#pick the frame for the small bubble
	if bubble_sprite:
		bubble_sprite.frame = 0

	get_tree().root.add_child(bubble)
	
