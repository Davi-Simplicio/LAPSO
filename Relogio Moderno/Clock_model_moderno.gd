extends StaticBody2D

@onready var interaction_label = $LabelModern
@onready var sprite = $Door/Sprite2DModern
@onready var collision = $CollisionShape2DModern

var player_nearby = false
var puzzle_aberto = false
var puzzle_instance = null

const PUZZLE_CENA = preload("res://Meu Relogio/Clock.tscn")

func _ready():
	if interaction_label:
		interaction_label.visible = false
	
	$InteractionAreaModerno.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionAreaModerno.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	if not is_visible_in_tree():
		if interaction_label:
			interaction_label.visible = false
		return

	if puzzle_aberto:
		var canvas = get_tree().root.get_node_or_null("PuzzleLayer")
		if not canvas or not is_instance_valid(canvas):
			_on_puzzle_fechado()
			return
	
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_resolvido
	
	if player_nearby and not puzzle_aberto and not ja_resolvido:
		interaction_label.visible = true
		if Input.is_action_just_pressed("interact"):
			abrir_puzzle()
	elif not player_nearby:
		interaction_label.visible = false

func abrir_puzzle():
	var canvas_antigo = get_tree().root.get_node_or_null("PuzzleLayer")
	if canvas_antigo and is_instance_valid(canvas_antigo):
		canvas_antigo.queue_free()
	
	puzzle_aberto = true
	puzzle_instance = null
	interaction_label.visible = false
	
	var canvas = CanvasLayer.new()
	canvas.name = "PuzzleLayer"
	canvas.layer = 10
	get_tree().root.add_child(canvas)
	
	puzzle_instance = PUZZLE_CENA.instantiate()
	canvas.add_child(puzzle_instance)
	
	var gear = puzzle_instance.get_node_or_null("GearControl")
	if gear and gear.has_signal("puzzle_fechado"):
		gear.puzzle_fechado.connect(_on_puzzle_fechado)

func _on_puzzle_fechado():
	puzzle_aberto = false
	puzzle_instance = null
	
	var canvas = get_tree().root.get_node_or_null("PuzzleLayer")
	if canvas and is_instance_valid(canvas):
		canvas.queue_free()
	
	var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_resolvido
	if player_nearby and not ja_resolvido and is_visible_in_tree():
		interaction_label.visible = true

func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		var ja_resolvido = has_node("/root/GameState") and get_node("/root/GameState").puzzle_relogio_resolvido
		if not puzzle_aberto and not ja_resolvido and is_visible_in_tree():
			interaction_label.visible = true
		
func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
