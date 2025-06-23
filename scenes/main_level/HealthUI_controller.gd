extends Control

var health = 3;
var max_health = 3;
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
@onready var healthFull = $HealthFull
@onready var healthEmpty = $HealthEmpty



func set_health(val):

	health = clamp(val, 0, max_health);
	if healthFull != null:
		healthFull.set_size(Vector2(health * 12, healthFull.size.y))
func _ready():
	player.connect("health_changed", self.set_health)
