extends CanvasLayer

# --- UI NODES ---
@onready var panel = $Panel
@onready var text_field = $Panel/TextField
@onready var choices_container = $Panel/ChoicesContainer
@onready var advance_button = $Panel/AdvanceButton
@onready var left_portrait = $Panel/LeftPortrait
@onready var left_name = $Panel/LeftName
@onready var right_portrait = $Panel/RightPortrait
@onready var right_name = $Panel/RightName

# --- DATA ---
var current_npc = null
var current_topic_lines: Array[String] = []
var current_line_index: int = 0
var is_typing: bool = false
var typing_speed: float = 0.02

# You might want a default texture for the player
# var player_texture = preload("res://path/to/player_face.png")

func _ready():
	panel.visible = false
	choices_container.visible = false

func start_dialogue(npc_data):
	current_npc = npc_data
	panel.visible = true
	get_tree().call_group("player", "set_move_state", false)
	right_portrait.texture = current_npc.portrait
	# --- SETUP PORTRAITS ---
	# Right side is always the NPC
	
	# Left side is the Player (you can set a static texture here if you want)
	# left_portrait.texture = player_texture 
	
	show_choice_menu()

func show_choice_menu():
	# Reset state
	advance_button.visible = false 
	choices_container.visible = true
	text_field.visible_ratio = 1.0
	
	# When in menu, show the NPC greeting and highlight the NPC
	update_active_speaker(current_npc.npc_name) 
	text_field.text = current_npc.greeting_text
	
	# Generate Buttons
	for child in choices_container.get_children():
		child.queue_free()
		
	for topic in current_npc.topics:
		if topic.required_fact_id != "" and not GameState.has_fact(topic.required_fact_id):
			continue 
			
		var btn = Button.new()
		btn.text = topic.button_label
		btn.pressed.connect(_on_topic_selected.bind(topic))
		choices_container.add_child(btn)

	var close = Button.new()
	close.text = "Goodbye"
	close.pressed.connect(close_dialogue)
	choices_container.add_child(close)

func _on_topic_selected(topic):
	choices_container.visible = false 
	advance_button.visible = true     
	current_topic_lines = topic.lines
	current_line_index = 0 
	show_next_line()

func show_next_line():
	if current_line_index >= current_topic_lines.size():
		show_choice_menu() 
		return

	var raw_text = current_topic_lines[current_line_index]
	
	# --- PARSING ---
	var speaker_name = "José" # Default Player Name
	var dialogue_text = raw_text
	
	if ": " in raw_text:
		var parts = raw_text.split(": ", true, 1) 
		speaker_name = parts[0]
		dialogue_text = parts[1]
	
	# --- VISIBILITY TOGGLE ---
	update_active_speaker(speaker_name)
	
	# Typewriter
	text_field.text = dialogue_text
	text_field.visible_ratio = 0.0
	if speaker_name != "José":
		text_field.horizontal_alignment = 2
	else:
		text_field.horizontal_alignment = 0
	is_typing = true
	var tween = create_tween()
	tween.tween_property(text_field, "visible_ratio", 1.0, dialogue_text.length() * typing_speed)
	tween.finished.connect(func(): is_typing = false)
	
	current_line_index += 1

# --- NEW FUNCTION: Only hides labels, dims portraits ---
func update_active_speaker(speaker_name):
	
	# Check if the speaker is the NPC
	if speaker_name == current_npc.npc_name:
		# --- NPC IS TALKING (RIGHT) ---
		right_name.text = speaker_name
		right_name.visible = true          # SHOW Name
		right_portrait.modulate.a = 1.0    # Bright Portrait
		
		# --- PLAYER IS LISTENING (LEFT) ---
		left_name.visible = false          # HIDE Name
		left_portrait.modulate.a = 0.5     # Dim Portrait (Optional)
		
	else:
		# --- PLAYER IS TALKING (LEFT) ---
		left_name.text = speaker_name
		left_name.visible = true           # SHOW Name
		left_portrait.modulate.a = 1.0     # Bright Portrait
		
		# --- NPC IS LISTENING (RIGHT) ---
		right_name.visible = false         # HIDE Name
		right_portrait.modulate.a = 0.5    # Dim Portrait (Optional)

func _on_advance_pressed():
	if is_typing:
		text_field.visible_ratio = 1.0
		is_typing = false
	else:
		show_next_line()

func close_dialogue():
	panel.visible = false
	get_tree().call_group("player", "set_move_state", true)
