extends Area2D
@export var cor_id: String
@export var is_left: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("SINAL DIRETO: Clique detectado no nó ", name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
