extends CanvasLayer

@onready var text_field = $Panel/TextField
@onready var portrait = $Panel/Portrait
@onready var panel = $Panel
@onready var close_button = $Panel/Button

# --- NEW: Reference to the container we just made ---
@onready var choices_container = $Panel/ChoicesContainer

var typing_speed = 0.02 
var current_npc = null # We need to remember who we are talking to
var is_reading_text = false # A flag to know if we are in "Menu Mode" or "Reading Mode"

func _ready():
	panel.visible = false
	choices_container.visible = false # Ensure buttons are hidden at start

# --- CHANGED: We now start by passing the whole NPC Resource, not just text ---
func start_dialogue(npc_data):
	current_npc = npc_data
	
	# Setup visual basics
	portrait.texture = npc_data.portrait 
	panel.visible = true
	get_tree().call_group("player", "set_move_state", false)
	
	# Start the loop
	show_choice_menu()

# --- NEW: This function generates the buttons ---
func show_choice_menu():
	is_reading_text = false
	text_field.text = "..." # Or npc_data.greeting_text if you have one
	text_field.visible_ratio = 1.0 # Show full greeting instantly
	
	# 1. Clear old buttons
	for child in choices_container.get_children():
		child.queue_free()
	
	# 2. Make visible
	choices_container.visible = true
	
	# 3. Create new buttons based on NPC topics
	for topic in current_npc.topics:
		# --- THE UNLOCK LOGIC ---
		# Check if this topic requires a fact from GameState
		if topic.required_fact_id != "":
			if not GameState.has_fact(topic.required_fact_id):
				continue # Skip this topic if we don't have the unlock!
		
		# Create Button
		var btn = Button.new()
		btn.text = topic.button_label
		# Connect click to our function
		btn.pressed.connect(_on_topic_selected.bind(topic))
		choices_container.add_child(btn)
		
	# 4. Always add a "Goodbye" option (optional)
	var close_btn = Button.new()
	close_btn.text = "Goodbye"
	close_btn.pressed.connect(close_dialogue)
	choices_container.add_child(close_btn)

# --- NEW: When a button is clicked ---
func _on_topic_selected(topic):
	# Hide buttons, show text
	choices_container.visible = false
	is_reading_text = true
	
	# If the topic has multiple lines, you might need a separate function 
	# to handle arrays. For now, let's assume 'lines' is one big string 
	# or we just show the first line:
	var text_content = topic.lines[0] 
	
	animate_text(text_content)

# --- REFACTORED: Moved the tween logic to its own helper function ---
func animate_text(text_to_show):
	text_field.text = text_to_show
	text_field.visible_ratio = 0.0
	
	var tween = create_tween()
	var duration = text_to_show.length() * typing_speed
	tween.tween_property(text_field, "visible_ratio", 1.0, duration)

func _unhandled_input(event):
	if panel.visible and event.is_action_pressed("interact"):
		
		# CASE 1: Text is still typing -> Skip to end
		if text_field.visible_ratio < 1.0:
			text_field.visible_ratio = 1.0
			# Tip: If you save the tween to a variable 'current_tween', 
			# you can do current_tween.kill() here to be safer.
			
		# CASE 2: Text finished AND we are reading a topic -> Go back to Menu
		elif is_reading_text:
			show_choice_menu() # <--- This loops us back to the buttons!
			
		# CASE 3: We are in the menu -> Do nothing (wait for button click)

func close_dialogue():
	get_tree().call_group("player", "set_move_state", true)
	panel.visible = false
	current_npc = null # Clean up

func _on_button_pressed():
	close_dialogue()
