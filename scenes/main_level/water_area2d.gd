extends Area2D

@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
func _ready():
	# Connect the body_entered signal to a function
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	# Optionally check if the body is the player
	if player:
		if body == player:
			print("Player entered the Water")
			player.is_in_water = true


func _on_body_exited(body):
	if player:
		if body == player:
			print("Player exited the Water!")
			player.is_in_water = false
