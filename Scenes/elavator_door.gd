extends StaticBody2D
@onready var interaction_label = $Label 
@onready var sprite = $Door/Sprite2D
@onready var collision = $CollisionShape2D
var player_nearby = false
var elevator_aberto = false
var elevator_instance = null
var time_manager = null
const ELEVATOR_SCENE = preload("res://Scenes/elevator_inside.tscn")

func _ready():
	if interaction_label:
		interaction_label.visible = false
	
	# Get reference to TimeManager (adjust the path if needed)
	time_manager = get_tree().root.get_node_or_null("TimeManager")
	if not time_manager:
		time_manager = get_node_or_null("/root/TimeManager")
	if not time_manager:
		push_warning("TimeManager not found!")
	
	$InteractionArea.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	if elevator_aberto:
		var canvas = get_tree().root.get_node_or_null("ElevatorLayer")
		if not canvas or not is_instance_valid(canvas):
			_on_elevator_closed()
			return
	
	if player_nearby and not elevator_aberto and Input.is_action_just_pressed("interact"):
		abrir_elevator()

func abrir_elevator():
	var canvas_antigo = get_tree().root.get_node_or_null("ElevatorLayer")
	if canvas_antigo and is_instance_valid(canvas_antigo):
		canvas_antigo.queue_free()
	
	elevator_aberto = true
	elevator_instance = null
	interaction_label.visible = false
	
	var canvas = CanvasLayer.new()
	canvas.name = "ElevatorLayer"
	canvas.layer = 10
	get_tree().root.add_child(canvas)
	
	elevator_instance = ELEVATOR_SCENE.instantiate()
	canvas.add_child(elevator_instance)
	
	# Conecta os sinais do elevador
	if elevator_instance:
		# Sinal para fechar o elevador
		if elevator_instance.has_signal("elevator_closed"):
			elevator_instance.elevator_closed.connect(_on_elevator_closed)
		
		# Sinal para mudar o tempo quando um andar é selecionado
		if elevator_instance.has_signal("time_changed"):
			elevator_instance.time_changed.connect(_on_time_changed)

func _on_elevator_closed():
	elevator_aberto = false
	elevator_instance = null
	
	var canvas = get_tree().root.get_node_or_null("ElevatorLayer")
	if canvas and is_instance_valid(canvas):
		canvas.queue_free()
	
	# Mostra o label novamente se o player ainda está perto
	if player_nearby:
		interaction_label.visible = true

func _on_time_changed(floor_number: int):
	if time_manager:
		time_manager.change_time_by_floor(floor_number)

func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		if not elevator_aberto:
			interaction_label.visible = true
		
func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
		
