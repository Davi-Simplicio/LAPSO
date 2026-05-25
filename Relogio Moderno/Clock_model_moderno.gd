extends StaticBody2D

@onready var interaction_label = $Label
@onready var sprite = $Door/Sprite2D
@onready var collision = $CollisionShape2D

var player_nearby = false
var puzzle_aberto = false
var puzzle_instance = null

const PUZZLE_CENA = preload("res://Relogio Moderno/ClockPuzzle.tscn")

func _ready():
	if interaction_label:
		interaction_label.visible = false
	$InteractionArea.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	if puzzle_aberto:
		var canvas = get_tree().root.get_node_or_null("PuzzleLayerModerno")
		if not canvas or not is_instance_valid(canvas):
			_on_puzzle_fechado()
			return

	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_moderno_resolvido

	if player_nearby and not puzzle_aberto and not ja_resolvido and Input.is_action_just_pressed("interact"):
		abrir_puzzle()

func abrir_puzzle():
	var canvas_antigo = get_tree().root.get_node_or_null("PuzzleLayerModerno")
	if canvas_antigo and is_instance_valid(canvas_antigo):
		canvas_antigo.queue_free()

	puzzle_aberto = true
	puzzle_instance = null
	interaction_label.visible = false

	var canvas = CanvasLayer.new()
	canvas.name = "PuzzleLayerModerno"
	canvas.layer = 10
	get_tree().root.add_child(canvas)

	puzzle_instance = PUZZLE_CENA.instantiate()
	canvas.add_child(puzzle_instance)

	# Conecta direto no puzzle_instance (não em um filho GearControl)
	if puzzle_instance.has_signal("puzzle_fechado"):
		puzzle_instance.puzzle_fechado.connect(_on_puzzle_fechado)

func _on_puzzle_fechado():
	puzzle_aberto = false
	puzzle_instance = null

	var canvas = get_tree().root.get_node_or_null("PuzzleLayerModerno")
	if canvas and is_instance_valid(canvas):
		canvas.queue_free()

	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_moderno_resolvido
	if player_nearby and not ja_resolvido:
		interaction_label.visible = true

func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_moderno_resolvido
		if not puzzle_aberto and not ja_resolvido:
			interaction_label.visible = true

func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
