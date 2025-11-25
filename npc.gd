extends CharacterBody2D

@onready var interaction_label = $Label
@onready var anim_player = $AnimationPlayer
@export_multiline var dialogue_text: String = "Hello!"
@export var face_texture: Texture2D  # <--- Drag the face image here in Inspector!
var player_in_range = false

func _ready():
	interaction_label.visible = false
	anim_player.play("idle")

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		start_dialogue()

func start_dialogue():
	# We call the group "dialogue_ui" and trigger the function "show_dialogue"
	# We pass 2 arguments: The text, and the face image.
	get_tree().call_group("dialogue_ui", "show_dialogue", dialogue_text, face_texture)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		interaction_label.visible = false
