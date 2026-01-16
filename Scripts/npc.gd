extends CharacterBody2D

@onready var interaction_label = $Label
@onready var anim_player = $AnimationPlayer
@export_multiline var dialogue_text: String = "Hello!"
@export var npc_data: NPCResource
var player_in_range = false
# Nodes
@onready var sprite = $Sprite2D

func _ready():
	setup_npc()

func setup_npc():
	if not npc_data:
		return
		
	# 1. Apply the Skin
	if npc_data.sprite_sheet:
		sprite.texture = npc_data.sprite_sheet
		sprite.hframes = npc_data.h_frames
		sprite.vframes = npc_data.v_frames
	
	# 2. Start the defined animation
	if npc_data.initial_animation != "":
		# Check if the animation actually exists to avoid errors
		if anim_player.has_animation(npc_data.initial_animation):
			anim_player.play(npc_data.initial_animation)
		else:
			print("Warning: Animation not found: ", npc_data.initial_animation)
	interaction_label.visible = false
	anim_player.play("idle")

func _unhandled_input(event):
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
