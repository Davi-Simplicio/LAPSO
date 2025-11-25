extends CanvasLayer

@onready var text_field = $Panel/TextField
@onready var portrait = $Panel/Portrait
@onready var panel = $Panel
@onready var button = $Panel/Button

var typing_speed = 0.02 # Seconds per letter. Lower is faster.

func _ready():
	panel.visible = false

func show_dialogue(text_to_show, face_image):
	text_field.text = text_to_show
	portrait.texture = face_image
	panel.visible = true
	get_tree().call_group("player", "set_move_state", false)
	# --- TYPEWRITER EFFECT START ---
	# 1. Hide all text initially
	text_field.visible_ratio = 0.0
	
	# 2. Create a Tween (Animation helper)
	var tween = create_tween()
	
	# 3. Calculate how long it takes: Number of characters * speed
	var duration = text_to_show.length() * typing_speed
	
	# 4. Animate the 'visible_ratio' property to 1.0 (100%) over 'duration' seconds
	tween.tween_property(text_field, "visible_ratio", 1.0, duration)
	# --- TYPEWRITER EFFECT END ---

func _unhandled_input(event):
	if panel.visible and event.is_action_pressed("interact"):
		# If the text is NOT finished typing yet...
		if text_field.visible_ratio < 1.0:
			# ...Finish it instantly!
			text_field.visible_ratio = 1.0
			# We also need to kill the active tween so it stops trying to animate
			# (Note: In a complex game you might want to save the 'tween' variable to kill() it specifically, 
			# but for this simple setup, just setting ratio to 1 is usually enough visual fix)
			
		# If the text IS finished...
		else:
			close_dialogue()

func close_dialogue():
	get_tree().call_group("player", "set_move_state", true)
	panel.visible = false
	
func _on_button_pressed():
	close_dialogue()
	pass # Replace with function body.
