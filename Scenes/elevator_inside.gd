extends Control

# The variable that controls if the elevator works
var is_functional: bool = false

@onready var display = $DisplayLabel

func _ready():
	# Set the initial state
	update_display("OUT OF ORDER")
	
	# Connect signals for all buttons
	# (You can also do this via the editor's Node tab)
	$Floor3Button.pressed.connect(_on_floor_pressed.bind(3))
	$Floor2Button.pressed.connect(_on_floor_pressed.bind(2))
	$Floor1Button.pressed.connect(_on_floor_pressed.bind(1))
	$HallButton.pressed.connect(_on_floor_pressed.bind(0))

func _on_floor_pressed(floor_number: int):
	if not is_functional:
		update_display("OUT OF ORDER")
		# Optional: Play a "error" buzz sound here
		return
	
	# If it is functional, handle the floor change
	match floor_number:
		0: update_display("HALL")
		1: update_display("1ST FLOOR")
		2: update_display("2ND FLOOR")
		3: update_display("3RD FLOOR")
	
	# Add your scene transition or elevator movement logic here

func update_display(text: String):
	display.text = text

# Call this function from elsewhere in your game to "fix" the elevator
func repair_elevator():
	is_functional = true
	update_display("READY")
