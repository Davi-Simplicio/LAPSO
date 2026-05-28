extends CanvasModulate



func _ready():
	# Ensure we start in the dark
	color = dark_co
	start_thunder_loop()

func start_thunder_loop():
	# 1. Wait for a random amount of time
	var wait_time = randf_range(min_interval, max_interval)
	await get_tree().create_timer(wait_time).timeout
	
	# 2. Trigger the flash
	trigger_flash()
	
	# 3. Restart the loop
	start_thunder_loop()
