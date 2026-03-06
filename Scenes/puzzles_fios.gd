extends Node2D
var active_wire: Line2D = null
var start_terminal = null
var hovered_terminal = null

func _ready():
	# Conecte os sinais de todos os terminais para detectar o mouse
	for t in get_tree().get_nodes_in_group("Terminals"):
		t.input_event.connect(_on_terminal_input.bind(t))
		t.mouse_entered.connect(func(): hovered_terminal = t)
		t.mouse_exited.connect(func(): hovered_terminal = null)

func _on_terminal_input(_viewport, event, _shape_idx, terminal):
	# INÍCIO DO ARRASTE
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if terminal.is_left:
			print("DEBUG: Iniciando fio a partir de: ", terminal.name, " (Cor: ", terminal.color_id, ")")
			start_terminal = terminal
			_create_wire(terminal)
		else:
			print("DEBUG: Clique ignorado. Terminal ", terminal.name, " é de destino (lado direito).")

func _process(_delta):
	# ARRASTANDO O FIO
	if active_wire:
		active_wire.set_point_position(1, get_local_mouse_position())
		
		# FINALIZAR O ARRASTE
		if Input.is_action_just_released("ui_accept") or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_finish_wire()

func _create_wire(terminal):
	active_wire = Line2D.new()
	active_wire.width = 10
	active_wire.default_color = Color.WHITE # Você pode pegar a cor do terminal aqui
	active_wire.add_point(terminal.global_position)
	active_wire.add_point(terminal.global_position) # Ponto inicial e final iguais
	active_wire.set_meta("color_id", terminal.color_id) # "Guarda a cor no Line2D"
	add_child(active_wire)

func _finish_wire():
	# VALIDAÇÃO LÓGICA
	if hovered_terminal and not hovered_terminal.is_left:
		if hovered_terminal.color_id == active_wire.get_meta("color_id"):
			# Conexão correta!
			active_wire.set_point_position(1, hovered_terminal.global_position)
			print("DEBUG: Soltou fio sobre: ", hovered_terminal.name)
			print("Conexão validada!")
		else:
			# Cor errada
			active_wire.queue_free()
	else:
		# Soltou no vazio
		active_wire.queue_free()
	
	active_wire = null
