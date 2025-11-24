extends Area2D

# This allows you to select the destination scene in the Inspector for each door
@export var destination_point: Marker2D

var player_is_in_range = false

func _ready():
	# Connect the signals using code (or do it via the Node tab)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var player_body = null

func _process(_delta):
	# Check if player is present AND presses the button
	if player_body != null and Input.is_action_just_pressed("interact"):
		teleport_player()

func teleport_player():
	if destination_point:
		# Move the player instantly to the marker's position
		player_body.global_position = destination_point.global_position
	else:
		print("Error: No destination Marker assigned to this door!")

# --- Signal Connections ---

func _on_body_entered(body):
	if body.name == "Player":
		player_body = body # Save the player so we can move them later

func _on_body_exited(body):
	if body.name == "Player":
		player_body = null # Clear the player when they walk away
