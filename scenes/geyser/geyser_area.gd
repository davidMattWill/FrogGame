extends Area2D

@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
func _ready():
	# Connect the body_entered signal to a function
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	# Optionally check if the body is the player
	var parent = get_parent()
	if parent and player:
		if body == player and parent.geyser_exploding == true:
			player._on_geyser_boost()
			
			
			
