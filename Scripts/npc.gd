@tool # 1. Added tool mode
extends CharacterBody2D

@onready var interaction_label = $Label
@onready var anim_player = $AnimationPlayer
@export_multiline var dialogue_text: String = "Hello!"

# 2. Added a setter to the NPC data
@export var npc_data: NPCResource:
	set(value):
		npc_data = value
		# In tool mode, nodes might not be ready yet, so we check
		if is_inside_tree():
			setup_npc()

var player_in_range = false

# Nodes
@onready var sprite = $Sprite2D

func _ready():
	setup_npc()

func setup_npc():
	# 3. Guard clause to prevent errors in editor if nodes aren't found yet
	if not sprite or not anim_player or not interaction_label:
		return
		
	if not npc_data:
		return
		
	# 1. Apply the Skin
	if npc_data.sprite_sheet:
		sprite.texture = npc_data.sprite_sheet
		sprite.hframes = npc_data.h_frames
		sprite.vframes = npc_data.v_frames
	
	# 2. Start the defined animation
	if npc_data.initial_animation != "":
		if anim_player.has_animation(npc_data.initial_animation):
			anim_player.play(npc_data.initial_animation)
		else:
			# Use push_warning instead of print for editor visibility
			push_warning("Animation not found: ", npc_data.initial_animation)
	
	# 4. Only hide labels and play 'idle' if we are actually playing the game
	if not Engine.is_editor_hint():
		interaction_label.visible = false
		if anim_player.has_animation("idle"):
			anim_player.play("idle")

func _unhandled_input(event):
	# 5. Prevent inputs from firing inside the Godot Editor
	if Engine.is_editor_hint():
		return
		
	if player_in_range and event.is_action_pressed("interact"):
		start_dialogue()

func start_dialogue():
	# We call the group "dialogue_ui" and trigger the function "show_dialogue"
	# We pass 2 arguments: The text, and the face image.
	DialogueBox.start_dialogue(npc_data)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		interaction_label.visible = false
