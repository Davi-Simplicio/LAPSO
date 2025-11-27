extends CanvasLayer

@onready var grid = $Panel/ScrollContainer/Grid

# MASTER LIST: Drag all your resources here (Doc1.tres, Doc2.tres...)
@export var all_documents_list: Array[DocumentResource] = []

func _ready():
	visible = false

func open_menu():
	visible = true
	refresh_grid()

func close_menu():
	visible = false

func refresh_grid():
	for child in grid.get_children():
		child.queue_free()
	
	# Loop through every possible document in the game
	for doc in all_documents_list:
		
		# --- KEY CHANGE: Check the string ID in GameState ---
		# We assume every document resource has a unique 'fact_id_to_unlock'
		var is_unlocked = GameState.has_fact(doc.fact_id_to_unlock)
		
		create_slot(doc, is_unlocked)

func create_slot(doc: DocumentResource, is_unlocked: bool):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(100, 100)
	btn.expand_icon = true
	
	# Always set the icon (we handle the visuals via color below)
	var tex = doc.icon if doc.icon else doc.full_image
	btn.icon = tex
	
	if is_unlocked:
		# Found it! Normal color.
		btn.modulate = Color(1, 1, 1, 1) 
		btn.tooltip_text = doc.doc_name
		btn.pressed.connect(func(): DocumentViewer.show_document(doc))
	else:
		# Not found! Silhouette (Black).
		btn.modulate = Color(0, 0, 0, 1)
		btn.tooltip_text = "???"
		btn.disabled = true
	
	grid.add_child(btn)
