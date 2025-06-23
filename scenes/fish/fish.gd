extends CharacterBody2D

var direction = 1.0
var speed = 5

@export var bubble_scene: PackedScene

@onready var ray_left: RayCast2D = $ray_left
@onready var ray_right: RayCast2D = $ray_right
@onready var fish_frames: Sprite2D = $fish_frames

@onready var marker: Marker2D = $fish_frames/Marker2D

func _ready():
	# set a random direction for the fish to idle
	direction = 1.0 if randf() > 0.5 else -1.0

func _physics_process(delta):
	#swap direction if we collide with something
	if ray_left.is_colliding() or ray_right.is_colliding():
		direction *= -1
		
	
	velocity.x = direction * speed
	move_and_slide()
	
	
	

func _process(delta):
	if randf() < 0.001:  # 1% chance per frame to idle
		direction *= -1
	if randf() < 0.005:  # 0.05% chance per frame to spawn a bubble
		spawn_bubble()
	if direction == -1:
		fish_frames.flip_h = true
	else:
		fish_frames.flip_h = false
		

func spawn_bubble():
	var bubble = bubble_scene.instantiate()
	#set the bubbles position to the marker
	bubble.global_position = marker.global_position
	var bubble_sprite = bubble.get_node("bubble_frames") as Sprite2D
	#pick the frame for the small bubble
	if bubble_sprite:
		bubble_sprite.frame = 0

	get_tree().root.add_child(bubble)
	
