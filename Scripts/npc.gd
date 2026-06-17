@tool
extends CharacterBody2D

@onready var interaction_label = $Label
@onready var sprite = $Sprite2D
@onready var idle_timer = $IdleTimer  # novo nó Timer

@export_multiline var dialogue_text: String = "Hello!"

@export var npc_data: NPCResource:
	set(value):
		npc_data = value
		if is_inside_tree():
			setup_npc()

var player_in_range = false
var current_frame_in_row = 0

func _ready():
	setup_npc()

func setup_npc():
	if not sprite or not interaction_label:
		return
	if not npc_data:
		return

	if npc_data.sprite_sheet:
		sprite.texture = npc_data.sprite_sheet
		sprite.hframes = npc_data.h_frames
		sprite.vframes = npc_data.v_frames
		sprite.frame = 0
		current_frame_in_row = 0

	if not Engine.is_editor_hint():
		interaction_label.visible = false
		start_idle_animation()

func start_idle_animation():
	if not idle_timer:
		return
	idle_timer.wait_time = 0.4  # velocidade da troca de frame, ajuste como quiser
	idle_timer.start()

func _on_idle_timer_timeout():
	if not npc_data or not sprite:
		return
	current_frame_in_row = (current_frame_in_row + 1) % npc_data.h_frames
	sprite.frame = current_frame_in_row  # linha 0 = frames 0..h_frames-1

func _unhandled_input(event):
	if Engine.is_editor_hint():
		return
	if player_in_range and event.is_action_pressed("interact"):
		start_dialogue()

func start_dialogue():
	DialogueBox.start_dialogue(npc_data)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		interaction_label.visible = false
