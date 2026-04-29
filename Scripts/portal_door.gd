extends Area2D

@export var destination_point: Marker2D

# 1. Get a reference to the Label node
@onready var interaction_label = $Label 

var player_body = null

func _ready():
	# Ensure label is hidden when game starts
	if interaction_label:
		interaction_label.visible = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_body != null and Input.is_action_just_pressed("interact"):
		open_door()

func open_door():
	var tween = create_tween()
	# Moves the door up by 32 pixels (one tile) smoothly
	tween.tween_property(self, "position:y", position.y - 32, 0.4).set_trans(Tween.TRANS_QUINT)
	# Disable collision so the player can walk through
	$CollisionShape2D.set_deferred("disabled", true)
	# Hide the "Press E" label
	interaction_label.visible = false
	# Stop processing so they can't "open" it twice
	set_process(false)
# --- Signal Connections ---

func _on_body_entered(body):
	if body.name == "Player": # Or body.is_in_group("player")
		player_body = body
		# 2. Show the label
		if interaction_label:
			interaction_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_body = null
		# 3. Hide the label
		if interaction_label:
			interaction_label.visible = false
