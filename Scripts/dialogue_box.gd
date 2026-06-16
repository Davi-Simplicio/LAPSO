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

# TEXTURA DO JOGADOR (Substitua pelo caminho correto da imagem do José)
var player_texture = preload("res://assets/NPC's/Gemini_Generated_Image_uho4opuho4opuho4-removebg-preview.png")

func _ready():
	panel.visible = false
	choices_container.visible = false
	
	# Esconde o lado direito permanentemente na inicialização
	right_portrait.visible = false
	right_name.visible = false

func start_dialogue(npc_data):
	current_npc = npc_data
	panel.visible = true
	get_tree().call_group("player", "set_move_state", false)
	
	# REMOVIDO: Não fixamos mais o retrato do NPC na direita aqui.
	
	show_choice_menu()

func show_choice_menu():
	# Reset state
	advance_button.visible = false 
	choices_container.visible = true
	text_field.visible_ratio = 1.0
	
	# Quando está no menu, o NPC é quem está falando
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
	close.text = "Tchau"
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
	
	# Opcional: Se quiser alinhar o texto dependendo de quem fala, pode manter.
	# Caso contrário, pode deixar sempre em 0 (esquerda).
	if speaker_name != "José":
		text_field.horizontal_alignment = 0
	else:
		text_field.horizontal_alignment = 0
		
	is_typing = true
	var tween = create_tween()
	tween.tween_property(text_field, "visible_ratio", 1.0, dialogue_text.length() * typing_speed)
	tween.finished.connect(func(): is_typing = false)
	
	current_line_index += 1

# --- FUNÇÃO ATUALIZADA: Altera a textura na esquerda e esconde a direita ---
func update_active_speaker(speaker_name):
	# Garantir que o lado direito fique sempre invisível
	right_name.visible = false
	right_portrait.visible = false
	
	# Sempre mostra o nome e retrato da esquerda
	left_name.visible = true
	left_portrait.visible = true
	left_portrait.modulate.a = 1.0 # Opacidade total
	
	left_name.text = speaker_name
	
	# Altera a foto baseado em quem está falando
	if speaker_name == current_npc.npc_name:
		# Se for o NPC falando, coloca a foto dele na esquerda
		left_portrait.texture = current_npc.portrait
	else:
		# Se for o jogador (José) falando, coloca a foto do jogador na esquerda
		left_portrait.texture = player_texture

func _on_advance_pressed():
	if is_typing:
		text_field.visible_ratio = 1.0
		is_typing = false
	else:
		show_next_line()

func close_dialogue():
	panel.visible = false
	get_tree().call_group("player", "set_move_state", true)
