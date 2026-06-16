extends StaticBody2D

@onready var interaction_label = $LabelFreeModel
@onready var sprite = $Door/Sprite2DFreeModel       # Ajuste o caminho se o seu objeto usar outro nó de sprite
@onready var collision = $CollisionShape2DFreeModel

var player_nearby = false
var puzzle_aberto = false
var puzzle_instance = null

# 1. MUDANÇA: Aponta para o arquivo do seu puzzle Flow Free
const PUZZLE_CENA = preload("res://Scenes/PuzzeleFlowFree.tscn") 

func _ready():
	if interaction_label:
		interaction_label.visible = false
	
	$InteractionAreaFreeModel.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionAreaFreeModel.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	if not is_visible_in_tree():
		if interaction_label:
			interaction_label.visible = false
		return

	if puzzle_aberto:
		var canvas = get_tree().root.get_node_or_null("PuzzleLayerFlowFree") 
		if not canvas or not is_instance_valid(canvas):
			_on_puzzle_fechado()
			return
	
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_flow_free_resolvido
	
	if player_nearby and not puzzle_aberto and not ja_resolvido:
		interaction_label.visible = true
		if Input.is_action_just_pressed("interact"):
			abrir_puzzle()
	elif not player_nearby:
		interaction_label.visible = false

func abrir_puzzle():
	var canvas_antigo = get_tree().root.get_node_or_null("PuzzleLayerFlowFree")
	if canvas_antigo and is_instance_valid(canvas_antigo):
		canvas_antigo.queue_free()
	
	puzzle_aberto = true
	puzzle_instance = null
	interaction_label.visible = false
	
	var canvas = CanvasLayer.new()
	canvas.name = "PuzzleLayerFlowFree"
	canvas.layer = 10
	get_tree().root.add_child(canvas)
	
	puzzle_instance = PUZZLE_CENA.instantiate()
	canvas.add_child(puzzle_instance)
	
	# Faz uma busca dinâmica pelo nó que contém o sinal dentro da cena
	_conectar_sinal_recursivo(puzzle_instance)

# Função recursiva que procura e conecta o sinal onde quer que ele esteja
func _conectar_sinal_recursivo(node: Node):
	if node.has_signal("puzzle_fechado"):
		if not node.puzzle_fechado.is_connected(_on_puzzle_fechado):
			node.puzzle_fechado.connect(_on_puzzle_fechado)
		return
		
	for child in node.get_children():
		_conectar_sinal_recursivo(child)

func _on_puzzle_fechado():
	puzzle_aberto = false
	puzzle_instance = null
	
	var canvas = get_tree().root.get_node_or_null("PuzzleLayerFlowFree")
	if canvas and is_instance_valid(canvas):
		canvas.queue_free()
	
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_flow_free_resolvido
	if player_nearby and not ja_resolvido and is_visible_in_tree():
		interaction_label.visible = true

func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_flow_free_resolvido
		if not puzzle_aberto and not ja_resolvido and is_visible_in_tree():
			interaction_label.visible = true
		
func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
