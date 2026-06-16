extends Control
signal elevator_closed
signal elevator_action_triggered(action_data)

# A dictionary tracking the functional state of each floor
# Key: floor number (int), Value: working or not (bool)
var floor_states: Dictionary = {
	0: false,   # Hall starts working
	1: false,  # 1st Floor is broken
	2: false,  # 2nd Floor is broken
	3: false   # 3rd Floor is broken
}

@onready var display = $DisplayLabel

func _ready():
	# Set the initial state
	update_display("READY")
	
	# Connect signals for all buttons
	$Floor3Button.pressed.connect(_on_floor_pressed.bind(3))
	$Floor2Button.pressed.connect(_on_floor_pressed.bind(2))
	$Floor1Button.pressed.connect(_on_floor_pressed.bind(1))
	$HallButton.pressed.connect(_on_floor_pressed.bind(0))

func _process(_delta):
	
	floor_states[1] = get_node("/root/GameState").puzzle_fios_resolvido
	floor_states[2] = get_node("/root/GameState").puzzle_fios_resolvido
	floor_states[3] = get_node("/root/GameState").puzzle_fios_resolvido
	
	# Verifica se ESC foi pressionado para fechar o elevador
	if Input.is_action_just_pressed("ui_cancel"):
		fechar_elevator()

func _on_floor_pressed(floor_number: int):
	# Check if the specific pressed floor is functional
	# safety check: if the floor doesn't exist in our dictionary, default to false
	if not floor_states.get(floor_number, false):
		update_display("Out of Service")
		# Optional: Play an error sound here
		return
	
	# If it is functional, handle the floor change
	match floor_number:
		0: 
			update_display("HALL")
			elevator_action_triggered.emit(0)
		1: 
			update_display("1st FLOOR")
			elevator_action_triggered.emit(1)
		2: 
			update_display("2nd FLOOR")
			elevator_action_triggered.emit(2)
		3: 
			update_display("3rd FLOOR")
			elevator_action_triggered.emit(3)
	
	# Add your scene transition or elevator movement logic here

func update_display(text: String):
	display.text = text

# Call this function to "fix" a specific floor (e.g., repair_floor(2))
func repair_floor(floor_number: int):
	if floor_states.has(floor_number):
		floor_states[floor_number] = true
		update_display("FLOOR " + str(floor_number) + " READY")

func fechar_elevator() -> void:
	elevator_closed.emit()

func _on_elevator_closed() -> void:
	pass # Replace with function body.


func _on_time_changed(floor_number: int) -> void:
	pass # Replace with function body.
