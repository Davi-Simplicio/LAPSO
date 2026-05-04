extends CanvasModulate

# 1. SETTINGS
# Your normal "Night" color (Copy the hex code you are currently using!)
@export var dark_color: Color = Color("25284dff") 

# The color of the lightning (Usually a bright, desaturated blue-white)
@export var lightning_color: Color = Color("#b0b0d0") 

# How often does it happen? (Seconds)
@export var min_interval: float = 15.0
@export var max_interval: float = 25.0

func _ready():
	# Ensure we start in the dark
	color = dark_color
	start_thunder_loop()

func start_thunder_loop():
	# 1. Wait for a random amount of time
	var wait_time = randf_range(min_interval, max_interval)
	await get_tree().create_timer(wait_time).timeout
	
	# 2. Trigger the flash
	trigger_flash()
	
	# 3. Restart the loop
	start_thunder_loop()

func trigger_flash():
	# Create a Tween to animate the color changing smoothly
	var tween = create_tween()
	
	# --- SEQUENCE OF FLASHES (Simulates flickering) ---
	
	# Flash 1: Instantly bright (0.05 seconds)
	tween.tween_property(self, "color", lightning_color, 0.05)
	
	# Dim slightly (flicker)
	var mid_color = dark_color.lerp(lightning_color, 0.5)
	tween.tween_property(self, "color", mid_color, 0.05)
	
	# Flash 2: Bright again
	tween.tween_property(self, "color", lightning_color, 0.05)
	
	# Fade out slowly back to dark (0.8 seconds)
	tween.tween_property(self, "color", dark_color, 0.8)
