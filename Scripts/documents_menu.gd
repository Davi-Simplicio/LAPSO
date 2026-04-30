extends CanvasLayer

@onready var grid = $Panel/MenuContainer/VBoxContainer/ScrollContainer/Grid

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
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(120, 140)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(120, 140)
	btn.expand_icon = true
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Always set the icon (we handle the visuals via color below)
	var tex = doc.icon if doc.icon else doc.full_image
	btn.icon = tex
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if is_unlocked:
		# Found it! Normal color with hover effect.
		btn.modulate = Color(1, 1, 1, 1)
		btn.tooltip_text = doc.doc_name
		btn.pressed.connect(func(): DocumentViewer.show_document(doc))
		
		# Add stylebox
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.2, 0.25, 0.3, 0.8)
		normal_style.border_color = Color(0.8, 0.6, 0.2, 0.6)
		normal_style.border_width_left = 2
		normal_style.border_width_top = 2
		normal_style.border_width_right = 2
		normal_style.border_width_bottom = 2
		normal_style.corner_radius_top_left = 6
		normal_style.corner_radius_top_right = 6
		normal_style.corner_radius_bottom_right = 6
		normal_style.corner_radius_bottom_left = 6
		
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.3, 0.35, 0.4, 0.9)
		hover_style.border_color = Color(0.9, 0.7, 0.3, 1)
		hover_style.border_width_left = 3
		hover_style.border_width_top = 3
		hover_style.border_width_right = 3
		hover_style.border_width_bottom = 3
		hover_style.corner_radius_top_left = 6
		hover_style.corner_radius_top_right = 6
		hover_style.corner_radius_bottom_right = 6
		hover_style.corner_radius_bottom_left = 6
		
		btn.add_theme_stylebox_override("normal", normal_style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("focus", hover_style)
		
		# Add label below icon
		var label = Label.new()
		label.text = doc.doc_name
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2, 1))
		label.custom_minimum_size = Vector2(110, 30)
		label.clip_text = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
	else:
		# Not found! Silhouette (Gray and locked).
		btn.modulate = Color(0.3, 0.3, 0.3, 0.6)
		btn.tooltip_text = "Unknown"
		btn.disabled = true
		
		# Add locked style
		var locked_style = StyleBoxFlat.new()
		locked_style.bg_color = Color(0.15, 0.15, 0.15, 0.6)
		locked_style.border_color = Color(0.4, 0.4, 0.4, 0.4)
		locked_style.border_width_left = 2
		locked_style.border_width_top = 2
		locked_style.border_width_right = 2
		locked_style.border_width_bottom = 2
		locked_style.corner_radius_top_left = 6
		locked_style.corner_radius_top_right = 6
		locked_style.corner_radius_bottom_right = 6
		locked_style.corner_radius_bottom_left = 6
		
		btn.add_theme_stylebox_override("normal", locked_style)
		btn.add_theme_stylebox_override("disabled", locked_style)
		
		# Add label below icon
		var label = Label.new()
		label.text = "???"
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.8))
		label.custom_minimum_size = Vector2(110, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	grid.add_child(btn)
