extends CanvasLayer

@onready var doc_image = $DocImage
@onready var background = $ColorRect

func _ready():
	visible = false

# Call this from your World Object
func show_document(data: DocumentResource):
	# 1. Update Visuals
	doc_image.texture = data.full_image
	visible = true
	
	# 2. Logic: Unlock the topic immediately when viewed!
	if data.fact_id_to_unlock != "":
		GameState.unlock_fact(data.fact_id_to_unlock)
		# Optional: Play a "New Clue" sound effect here

func close_document():
	visible = false
