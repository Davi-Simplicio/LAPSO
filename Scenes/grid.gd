extends TileMapLayer

@export_group("Configurações do Grid")
@export var grid_width: int = 16 
@export var grid_height: int = 16
@export var tile_atlas_pos: Vector2i = Vector2i(0, 0)
@export var source_id: int = 0

@export_group("Cenas e Nós")
@export var terminal_scene: PackedScene 
@onready var lines_container = $LinesContainer 

# --- Lógica de Jogo ---
# Ajustado para ocupar as extremidades reais de um grid 16x16 (0 a 15)
var level_data = {
	"red": [Vector2i(0, 0), Vector2i(15, 0)],      # Canto superior esquerdo ao superior direito
	"blue": [Vector2i(0, 15), Vector2i(15, 15)],   # Canto inferior esquerdo ao inferior direito
	"green": [Vector2i(0, 5), Vector2i(15, 5)],    # Travessia horizontal no terço superior
	"yellow": [Vector2i(5, 0), Vector2i(5, 15)],   # Travessia vertical à esquerda
	"orange": [Vector2i(10, 0), Vector2i(10, 15)], # Travessia vertical à direita
	"purple": [Vector2i(0, 10), Vector2i(15, 10)], # Travessia horizontal no terço inferior
	"cyan": [Vector2i(7, 7), Vector2i(8, 8)]       # Conexão curta no centro exato
}

var color_palette = {
	"red": Color.RED,
	"blue": Color.BLUE,
	"green": Color.GREEN,
	"yellow": Color.YELLOW,
	"orange": Color.ORANGE,
	"purple": Color.PURPLE,
	"cyan": Color.CYAN
}

var grid_data = {} 
var is_drawing: bool = false
var current_line: Line2D = null
var current_color_id: String = ""
var last_pos: Vector2i

func _ready():
	generate_grid()
	spawn_terminals()

func generate_grid():
	clear()
	grid_data.clear()
	
	# Usamos uma cor levemente cinza e transparente
	# Isso ajuda a ver o fundo escuro do jogo através das frestas (grade)
	self.self_modulate = Color(1, 1, 1, 0.4)
	
	for x in range(grid_width):
		for y in range(grid_height):
			set_cell(Vector2i(x, y), source_id, tile_atlas_pos)
			grid_data[Vector2i(x, y)] = null
			
func spawn_terminals():
	# Limpa terminais antigos se existirem (bom para restart de fase)
	for child in get_children():
		if child is Node2D and child.name.contains("Terminal"):
			child.queue_free()

	for color_id in level_data:
		if not color_palette.has(color_id): continue # Pula se esquecer a cor na paleta
		
		var positions = level_data[color_id]
		for pos in positions:
			var t = terminal_scene.instantiate()
			add_child(t)
			t.position = map_to_local(pos)
			# Garante que o setup mude a cor do círculo branco
			if t.has_method("setup"):
				t.setup(color_id, color_palette[color_id])
			
			grid_data[pos] = {"type": "terminal", "color": color_id}

# --- Sistema de Input (Mantido igual, pois já funciona com grid_data) ---

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing()
			else:
				stop_drawing()
				
	if event is InputEventMouseMotion and is_drawing:
		continue_drawing()

func start_drawing():
	var m_pos = get_local_mouse_position()
	var g_pos = local_to_map(m_pos)
	
	if grid_data.has(g_pos) and grid_data[g_pos] != null:
		if grid_data[g_pos].type == "terminal":
			is_drawing = true
			current_color_id = grid_data[g_pos].color
			last_pos = g_pos
			create_new_line(color_palette[current_color_id], map_to_local(g_pos))

func create_new_line(color: Color, start_pos: Vector2):
	current_line = Line2D.new()
	lines_container.add_child(current_line)
	
	current_line.default_color = color
	current_line.width = 10 # Um pouco mais fino para o grid 16x16 não poluir
	current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	current_line.add_point(start_pos)

func continue_drawing():
	var g_pos = local_to_map(get_local_mouse_position())
	
	if g_pos != last_pos and grid_data.has(g_pos):
		var diff = (g_pos - last_pos).abs()
		if diff.x + diff.y == 1:
			# Só desenha se a célula estiver vazia ou se for o terminal de destino
			if grid_data[g_pos] == null or (grid_data[g_pos].type == "terminal" and grid_data[g_pos].color == current_color_id):
				last_pos = g_pos
				current_line.add_point(map_to_local(g_pos))
				
				if grid_data[g_pos] == null:
					grid_data[g_pos] = {"type": "path", "color": current_color_id}

func stop_drawing():
	is_drawing = false
	current_line = null
