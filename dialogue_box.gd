extends CanvasLayer

# --- UI NODES ---
@onready var panel = $Panel
@onready var portrait = $Panel/Portrait
@onready var name_label = $Panel/NameLabel     # <--- NEED THIS for the name
@onready var text_field = $Panel/TextField
@onready var choices_container = $Panel/ChoicesContainer
@onready var advance_button = $Panel/AdvanceButton # <--- The button we just made

# --- DATA ---
var current_npc = null
var current_topic_lines: Array[String] = []
var current_line_index: int = 0
var is_typing: bool = false
var typing_speed: float = 0.02

func _ready():
	panel.visible = false
	choices_container.visible = false
	# Connect the full-screen button to our advance function

func start_dialogue(npc_data):
	current_npc = npc_data
	panel.visible = true
	get_tree().call_group("player", "set_move_state", false)
	show_choice_menu() # Start at the menu

func show_choice_menu():
	# Reset state
	advance_button.visible = false # Disable clicking while choosing
	choices_container.visible = true
	text_field.visible_ratio = 1.0
	
	# Show Greeting
	update_content(current_npc.npc_name, current_npc.greeting_text)
	
	# Generate Buttons (Same as before)
	for child in choices_container.get_children():
		child.queue_free()
		
	for topic in current_npc.topics:
		if topic.required_fact_id != "" and not GameState.has_fact(topic.required_fact_id):
			continue # Locked
			
		var btn = Button.new()
		btn.text = topic.button_label
		btn.pressed.connect(_on_topic_selected.bind(topic))
		choices_container.add_child(btn)

	# Exit Button
	var close = Button.new()
	close.text = "Goodbye"
	close.pressed.connect(close_dialogue)
	choices_container.add_child(close)

# --- CLICKING A TOPIC STARTS THE CHAT LOOP ---
func _on_topic_selected(topic):
	choices_container.visible = false # Hide choices
	advance_button.visible = true     # Enable "Click to Next"
	
	# Load the lines
	current_topic_lines = topic.lines
	current_line_index = 0 
	
	show_next_line()

# --- THE LOGIC TO ADVANCE TEXT ---
func show_next_line():
	# 1. Check if we reached the end of the array
	if current_line_index >= current_topic_lines.size():
		show_choice_menu() # Go back to buttons
		return

	# 2. Get the current raw line (e.g. "Player: What is this?")
	var raw_text = current_topic_lines[current_line_index]
	
	# 3. PARSE THE NAME (Split by ":")
	var speaker_name = current_npc.npc_name # Default to NPC
	var dialogue_text = raw_text
	
	if ": " in raw_text:
		var parts = raw_text.split(": ", true, 1) # Split only on first ':'
		speaker_name = parts[0]
		dialogue_text = parts[1]
		
		# Optional: Change portrait based on name?
		# if speaker_name == "Player": portrait.texture = player_face
	
	# 4. Show it
	update_content(speaker_name, dialogue_text)
	
	# 5. Typewriter Effect
	text_field.visible_ratio = 0.0
	is_typing = true
	var tween = create_tween()
	tween.tween_property(text_field, "visible_ratio", 1.0, dialogue_text.length() * typing_speed)
	tween.finished.connect(func(): is_typing = false)
	
	# 6. IMPORTANT: Prepare index for NEXT click
	current_line_index += 1

# --- THE INPUT HANDLER ---
func _on_advance_pressed():
	# If typing, finish instantly
	if is_typing:
		text_field.visible_ratio = 1.0
		is_typing = false
		# Kill active tweens if you want perfect safety, but usually this is enough
	else:
		# If done typing, load the NEXT line
		show_next_line()

# --- HELPER TO UPDATE UI ---
func update_content(name_text, dialogue_text):
	name_label.text = name_text
	text_field.text = dialogue_text

func close_dialogue():
	panel.visible = false
	get_tree().call_group("player", "set_move_state", true)
