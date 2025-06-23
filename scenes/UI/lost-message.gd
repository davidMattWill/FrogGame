extends Sprite2D

# Time to fully reveal the sprite (in seconds, adjust to approximate per-letter timing)
@export var reveal_duration: float = 2.0
@onready var player: CharacterBody2D = get_node("/root/main_level/PlayerCharacter")
# Internal variables
var reveal_progress: float = 0.0
var is_revealing: bool = false


func _ready():
	player.connect("player_dead", self._on_player_dead)
	
	# Apply the shader if not already set
	if not material or not material.shader:
		material = ShaderMaterial.new()
		material.shader = Shader.new()
		material.shader.code = """
		shader_type canvas_item;
		uniform float progress : hint_range(0.0, 1.0) = 0.0;
		
		void fragment() {
			vec4 color = texture(TEXTURE, UV);
			if (UV.x > progress) {
				color.a = 0.0; // Hide pixels beyond progress
			}
			COLOR = color;
		}
		"""
	# Initialize shader progress
	material.set_shader_parameter("progress", 0.0)
	# Start revealing when instanced
	start_reveal()

func _on_visibility_changed():
	# Restart reveal when visibility changes to true
	if visible and not is_revealing:
		start_reveal()

func _on_player_dead():
	self.visible = true

func start_reveal():
	# Reset and start the reveal
	reveal_progress = 0.0
	material.set_shader_parameter("progress", 0.0)
	is_revealing = true


func _process(delta):
	if is_revealing:
		# Increment reveal progress
		reveal_progress += delta / reveal_duration
		if reveal_progress >= 1.0:
			reveal_progress = 1.0
			is_revealing = false
		# Update shader progress
		material.set_shader_parameter("progress", reveal_progress)
