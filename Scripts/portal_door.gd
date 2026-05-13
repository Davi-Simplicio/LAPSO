extends StaticBody2D # Change root node type to StaticBody2D

@onready var interaction_label = $Label 
@onready var sprite = $Door/Sprite2D # Make sure your door image is a child named Sprite2D
@onready var collision = $CollisionShape2D

var player_nearby = false
var is_open = false

func _ready():
	if interaction_label:
		interaction_label.visible = false
	
	# Connect the signals from the new Area2D node
	$InteractionArea.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta):
	# Using "is_open == false" prevents re-triggering the animation while it's fading
	if player_nearby and not is_open and Input.is_action_just_pressed("interact"):
		fade_door_open()

func fade_door_open():
	is_open = true
	interaction_label.visible = false
	
	var tween = create_tween()
	
	# 1. Fade the sprite alpha to 0 over 0.5 seconds
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	# 2. Disable the collision so player can walk through
	collision.set_deferred("disabled", true)
	
	# Optional: Remove the door entirely after it fades to save memory
	# tween.finished.connect(queue_free)

# --- Proximity Logic (Using a child Area2D) ---
		
func _on_interaction_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = true
		if not is_open:
			interaction_label.visible = true
			
func _on_interaction_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_nearby = false
		interaction_label.visible = false
