extends Control

var digits = [0, 0, 0, 0]
@onready var labels = [$Value1, $Value2, $Value3, $Value4]

# Referência ao container que tem o display de números e botões
# Ajuste o caminho conforme sua árvore real (ex: $HBoxContainer)
@onready var display_container = $HBoxContainer

# Referência ao Label/mensagem de "falta algo"
# Crie esse node na cena (ex: um Label chamado MissingMessage)
@onready var missing_message = $MissingMessage

# Set your hardcoded target value here
const TARGET_VALUE = "7252"


func _ready():
	$PlusValue1.pressed.connect(change_digit.bind(0, 1))
	$PlusValue2.pressed.connect(change_digit.bind(1, 1))
	$PlusValue3.pressed.connect(change_digit.bind(2, 1))
	$PlusValue4.pressed.connect(change_digit.bind(3, 1))

	$MinorValue1.pressed.connect(change_digit.bind(0, -1))
	$MinorValue2.pressed.connect(change_digit.bind(1, -1))
	$MinorValue3.pressed.connect(change_digit.bind(2, -1))
	$MinorValue4.pressed.connect(change_digit.bind(3, -1))

	# Connect the new Try button
	$Try.pressed.connect(_on_try_pressed)

	update_labels()
	check_puzzles_status()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		sair_do_puzzle()
		return
	pass


func check_puzzles_status() -> void:
	var todos_resolvidos = (
		GameState.puzzle_relogio_resolvido
		and GameState.puzzle_fios_resolvido
		and GameState.puzzle_flow_free_resolvido
		and GameState.puzzle_relogio_moderno_resolvido
	)

	display_container.visible = todos_resolvidos
	missing_message.visible = not todos_resolvidos


func sair_do_puzzle():
	queue_free()


func change_digit(index: int, amount: int):
	digits[index] = (digits[index] + amount + 10) % 10
	update_labels()


func update_labels():
	for i in range(4):
		labels[i].text = str(digits[i])


func get_final_number() -> String:
	var final_string = ""
	for digit in digits:
		final_string += str(digit)
	return final_string


func _on_try_pressed():
	if get_final_number() == TARGET_VALUE:
		# Replace the path below with the path to your actual scene
		get_tree().change_scene_to_file("res://HotelScreens/end_screen.tscn")
	else:
		print("Parece que nao funcionou")
