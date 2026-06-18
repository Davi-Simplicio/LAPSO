extends Area2D

@export var doc_data: DocumentResource
@onready var sprite = $TextureRect
@onready var label = $Label

var is_player_close = false

func _ready():
	if label: label.visible = false
	
	# PERSISTENCE CHECK:
	# Instead of checking a "document list", we check if the ID is unlocked.
	if doc_data and GameState.has_fact(doc_data.fact_id_to_unlock):
		queue_free()
		return

	if doc_data:
		sprite.texture = doc_data.icon if doc_data.icon else doc_data.full_image

func _unhandled_input(event):
	if is_player_close and event.is_action_pressed("interact"):
		interact()
		get_viewport().set_input_as_handled()

func interact():
	if doc_data:
		# --- KEY CHANGE: Just use your existing Unlock system ---
		DocumentViewer.show_document(doc_data)
		GameState.unlock_fact(doc_data.fact_id_to_unlock)
		print(GameState.unlocked_facts)
		# Optional: Play sound or show popup
		queue_free()

# --- PROXIMITY ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		is_player_close = true # <--- Player is here!
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_player_close = false # <--- Player left!
		label.visible = false
