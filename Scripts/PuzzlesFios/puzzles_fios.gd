extends Node2D

var active_wire: Line2D = null
var current_cor_id: String = ""
var start_pos: Vector2 = Vector2.ZERO

signal puzzle_fechado

# Exemplo de função quando o jogador clica no botão "Sair" ou resolve o puzzle:
func _on_botao_sair_pressed():
	puzzle_fechado.emit()
	
func _ready():
	print("DEBUG: Sistema de Puzzles iniciado.")
	# Conectamos o sinal de clique de todos os Area2D que estão nos containers
	# Certifique-se de que seus terminais estão no grupo "terminals"
	for terminal in get_tree().get_nodes_in_group("terminals"):
		terminal.input_event.connect(_on_terminal_input.bind(terminal))
		print("DEBUG: Terminal conectado: ", terminal.name)

func _process(_delta):
	# Se existir um fio sendo arrastado, o segundo ponto segue o mouse
	if active_wire != null:
		active_wire.set_point_position(1, get_local_mouse_position())
		
		# Se soltar o botão do mouse, tentamos finalizar a conexão
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_finalizar_conexao()

func _on_terminal_input(_viewport, event, _shape_idx, terminal):
	# VERIFICAÇÃO DE SEGURANÇA: O nó clicado tem a variável necessária?
	if not "cor_id" in terminal:
		print("ERRO: O nó ", terminal.name, " não tem a variável 'color_id'. Verifique o script!")
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if terminal.is_left:
			print("DEBUG: Iniciando fio da cor: ", terminal.cor_id)
			_criar_novo_fio(terminal)
		else:
			print("DEBUG: Clique ignorado. Comece pelo lado esquerdo.")

func _criar_novo_fio(terminal):
	active_wire = Line2D.new()
	
	# Configurações Visuais do Line2D
	active_wire.width = 10
	active_wire.default_color = _obter_cor_pelo_id(terminal.cor_id)
	active_wire.joint_mode = Line2D.LINE_JOINT_ROUND
	active_wire.begin_cap_mode = Line2D.LINE_CAP_ROUND
	active_wire.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Guardamos a cor para validar depois
	current_cor_id = terminal.cor_id
	start_pos = terminal.global_position
	
	# Adiciona os dois pontos iniciais (origem e mouse)
	active_wire.add_point(terminal.global_position)
	active_wire.add_point(get_local_mouse_position())
	
	add_child(active_wire)

var conexoes_corretas: int = 0
var total_conexoes_necessarias: int = 6 # Altere conforme o número de pares

func _finalizar_conexao():
	var terminal_destino = _obter_terminal_sob_mouse()
	
	if terminal_destino != null and not terminal_destino.is_left:
		# Verifica se o terminal já está conectado para evitar trapaça
		if terminal_destino.has_meta("conectado") and terminal_destino.get_meta("conectado"):
			print("DEBUG: Este terminal já possui um fio!")
			active_wire.queue_free()
		elif terminal_destino.cor_id == current_cor_id:
			print("SUCESSO: Cores batem!")
			active_wire.set_point_position(1, terminal_destino.global_position)
			
			# MARCAR COMO CONECTADO
			terminal_destino.set_meta("conectado", true)
			conexoes_corretas += 1
			_verificar_vitoria()
		else:
			print("ERRO: Cor errada!")
			active_wire.queue_free()
	else:
		active_wire.queue_free()
	
	active_wire = null

func _verificar_vitoria():
	print("Progresso: ", conexoes_corretas, "/", total_conexoes_necessarias)
	if conexoes_corretas >= total_conexoes_necessarias:
		print("VITÓRIA! Todos os fios foram conectados.")
		GameState.puzzle_fios_resolvido = true
		puzzle_fechado.emit()
		#_disparar_efeito_vitoria()



# Função auxiliar para detectar qual terminal o mouse está em cima ao soltar
func _obter_terminal_sob_mouse():
	for terminal in get_tree().get_nodes_in_group("terminals"):
		# Verifica se o mouse está na área
		if terminal.get_node("CollisionShape2D").get_shape().get_rect().has_point(terminal.get_local_mouse_position()):
			# SÓ RETORNA SE TIVER A VARIÁVEL
			if "cor_id" in terminal:
				return terminal
	return null

# Função para converter o nome da cor em uma cor real do Godot
func _obter_cor_pelo_id(id: String) -> Color:
	match id.to_lower():
		"azul": return Color.from_string("28C5FF",Color.WHITE)
		"laranja": return Color.from_string("F92300",Color.WHITE)
		"verde": return Color.from_string("00F306",Color.WHITE)
		"amarelo": return Color.from_string("FFFF00",Color.WHITE)
		"rosa": return Color.from_string("FF03F4",Color.WHITE)
		"roxo": return Color.from_string("5600EB",Color.WHITE)
		_: return Color.WHITE
