extends Node2D


@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
@export var bubble_scene: PackedScene

@onready var marker_1: Marker2D = $marker_1
@onready var marker_2: Marker2D = $marker_2
@onready var marker_3: Marker2D = $marker_3
var markers = []

var geyser_exploding = false
var geyser_time = 0.0
var geyser_time_max = 10

var bubble_probability = 0.2
var medium_bubble_probability = 0.20
var large_bubble_probability = 0.05

var angle_bound = 10
var max_distance = 100
var min_distance = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	markers = [marker_1, marker_2, marker_3]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not geyser_exploding:
		if randf() < 0.001:  # 1% chance per frame to initiate geyser explosion
			geyser_exploding = true
			geyser_time = 0.0
	else:
		if geyser_time <= geyser_time_max:
			if randf() < bubble_probability:
				spawn_bubble()
			geyser_time += delta
		else:
			geyser_exploding = false
		
func spawn_bubble():
	for marker in markers:
		var bubble = bubble_scene.instantiate()
		#set the bubbles position to the marker
		bubble.global_position = marker.global_position
		var bubble_sprite = bubble.get_node("bubble_frames") as Sprite2D
		#pick the frame for the small bubble
		if bubble_sprite:
			var rand_val = randf()
			if rand_val >= medium_bubble_probability:
				bubble_sprite.frame = 0
			if rand_val < medium_bubble_probability and rand_val >= 0.05:
				bubble_sprite.frame = 1
			if rand_val < 0.05:
				bubble_sprite.frame = 2
		

		get_tree().root.add_child(bubble)
	
