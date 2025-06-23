extends Marker2D


@onready var parent_sprite = get_parent() as Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#The marker should match the orientation of the fish for generating correct bubbles
	if parent_sprite:
		position.x = -8 if parent_sprite.flip_h else 8
