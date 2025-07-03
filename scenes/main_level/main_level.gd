extends Node2D
@onready var animation_player: AnimationPlayer = $main_level_animation_player
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")



# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_dead", _on_player_dead)
	animation_player.connect("animation_finished", _on_animation_finished)
func _on_player_dead():
	#play the fade out animation
	animation_player.play("fade_out")
	#load the game over scene into main
	
func _on_animation_finished(anim_name: String):
	print("anim_name")
	if anim_name == "fade_out":
		var game_over_scene = load("res://scenes/game_over.tscn") as PackedScene
		get_tree().change_scene_to_packed(game_over_scene)
	
