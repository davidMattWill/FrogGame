extends Area2D

# Reference to the AnimatedSprite2D node (assign in the editor or code)
@onready var sprite = $try_again_button


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the input_event signal of Area2D to detect mouse clicks
	input_event.connect(_on_input_event)
	sprite.connect("animation_finished", _on_animation_finished)
	

# Handle input events (mouse clicks)
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		sprite.play("click")  # Play the "click" animation on the AnimatedSprite2D

# Optional: Return to a default animation after the click animation finishes
func _on_animation_finished():
	var main_level =  load("res://scenes/main_level/main_level.tscn") as PackedScene
	get_tree().change_scene_to_packed(main_level)
