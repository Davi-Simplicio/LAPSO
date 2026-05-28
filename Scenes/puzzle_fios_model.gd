extends StaticBody2D

@onready var interaction_label = $LabelFiosModel 
@onready var sprite = $Door/Sprite2DFiosModel           # Ajuste o caminho se o seu objeto de fios usar outro nó de sprite
@onready var collision = $CollisionShape2DFiosModel 

var player_nearby = false
var puzzle_aberto = false
var puzzle_instance = null

# 1. MUDANÇA: Aponta para o arquivo do seu puzzle de fios
const PUZZLE_CENA = preload("res://Scenes/PuzzlesFios.tscn") 

func _ready():
	if interaction_label:
		interaction_label.visible = false
	
	$InteractionAreaFiosModel.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionAreaFiosModel.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	if not is_visible_in_tree():
		if interaction_label:
			interaction_label.visible = false
		return

	if puzzle_aberto:
		var canvas = get_tree().root.get_node_or_null("PuzzleLayerFios") # Nome único para não conflitar com o relógio
		if not canvas or not is_instance_valid(canvas):
			_on_puzzle_fechado()
			return
	
	# 2. MUDANÇA: Nova variável que você deve criar no seu GameState.gd
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_fios_resolvido
	
	if player_nearby and not puzzle_aberto and not ja_resolvido:
		interaction_label.visible = true
		if Input.is_action_just_pressed("interact"):
			abrir_puzzle()
	elif not player_nearby:
		interaction_label.visible = false

func abrir_puzzle():
	var canvas_antigo = get_tree().root.get_node_or_null("PuzzleLayerFios")
	if canvas_antigo and is_instance_valid(canvas_antigo):
		canvas_antigo.queue_free()
	
	puzzle_aberto = true
	puzzle_instance = null
	interaction_label.visible = false
	
	var canvas = CanvasLayer.new()
	canvas.name = "PuzzleLayerFios"
	canvas.layer = 10
	get_tree().root.add_child(canvas)
	
	puzzle_instance = PUZZLE_CENA.instantiate()
	canvas.add_child(puzzle_instance)
	
	# 3. MUDANÇA: Conectando o sinal de fechamento. 
	# Tentamos conectar direto na raiz do puzzle de fios. Se ele usar outro nó interno, mude o nome aqui:
	if puzzle_instance.has_signal("puzzle_fechado"):
		puzzle_instance.puzzle_fechado.connect(_on_puzzle_fechado)
	else:
		# Caso o sinal esteja dentro de um nó de controle do puzzle de fios (ex: "WireControl")
		var controle_fios = puzzle_instance.get_node_or_null("WireControl")
		if controle_fios and controle_fios.has_signal("puzzle_fechado"):
			controle_fios.puzzle_fechado.connect(_on_puzzle_fechado)

func _on_puzzle_fechado():
	puzzle_aberto = false
	puzzle_instance = null
	
	var canvas = get_tree().root.get_node_or_null("PuzzleLayerFios")
	if canvas and is_instance_valid(canvas):
		canvas.queue_free()
	
	# 4. MUDANÇA: Checa a variável correta dos fios ao fechar
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_fios_resolvido
	if player_nearby and not ja_resolvido and is_visible_in_tree():
		interaction_label.visible = true

func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		# 5. MUDANÇA: Checa a variável correta dos fios ao entrar na área
		var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_fios_resolvido
		if not puzzle_aberto and not ja_resolvido and is_visible_in_tree():
			interaction_label.visible = true
		
func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
