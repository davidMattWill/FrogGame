extends TextureProgressBar

var space_held: bool = false
var hold_time = 0.0
var max_hold_time = 2.0

@onready var player: CharacterBody2D = get_parent()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		space_held = true
		hold_time = 0.0
		self.visible = true
	
	if Input.is_action_just_pressed("ui_accept") and space_held:
		hold_time += delta
		hold_time = min(hold_time, max_hold_time)
		self.value = (hold_time / max_hold_time) * 100
		
	if Input.is_action_just_released("ui_accept") and space_held:
		space_held = false
		self.visible = false
		
		player.
		
	
