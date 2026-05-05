extends TileMapLayer

@export_group("Configurações do Grid")
@export var grid_width: int = 16 
@export var grid_height: int = 16
@export var tile_atlas_pos: Vector2i = Vector2i(0, 0)
@export var source_id: int = 0

@export_group("Cenas e Nós")
@export var terminal_scene: PackedScene 

var lines_container: Node2D 

# Layout resolvível e balanceado
var level_data = {
	"red":    [Vector2i(1, 1),   Vector2i(1, 14)],
	"blue":   [Vector2i(14, 1),  Vector2i(14, 14)],
	"green":  [Vector2i(3, 1),   Vector2i(12, 1)],
	"yellow": [Vector2i(3, 14),  Vector2i(12, 14)],
	"orange": [Vector2i(5, 4),   Vector2i(5, 11)],
	"purple": [Vector2i(10, 4),  Vector2i(10, 11)],
	"cyan":   [Vector2i(7, 7),   Vector2i(8, 7)]
}

var color_palette = {
	"red": Color.RED, "blue": Color.BLUE, "green": Color.GREEN,
	"yellow": Color.YELLOW, "orange": Color.ORANGE, 
	"purple": Color.PURPLE, "cyan": Color.CYAN
}

var grid_data = {} 
var active_lines = {} 
var is_drawing: bool = false
var current_line: Line2D = null
var current_color_id: String = ""
var last_pos: Vector2i
var completed_colors = [] 

func _ready():
	setup_lines_container()
	generate_grid()
	spawn_terminals()

func setup_lines_container():
	lines_container = get_node_or_null("LinesContainer")
	if lines_container == null:
		lines_container = Node2D.new()
		lines_container.name = "LinesContainer"
		add_child(lines_container)

func generate_grid():
	clear()
	grid_data.clear()
	self.self_modulate = Color(1, 1, 1, 0.4)
	for x in range(grid_width):
		for y in range(grid_height):
			set_cell(Vector2i(x, y), source_id, tile_atlas_pos)
			grid_data[Vector2i(x, y)] = null
			
func spawn_terminals():
	for child in get_children():
		if child is Node2D and child.name.contains("Terminal"):
			child.queue_free()
	for color_id in level_data:
		for pos in level_data[color_id]:
			var t = terminal_scene.instantiate()
			add_child(t)
			t.position = map_to_local(pos)
			if t.has_method("setup"): t.setup(color_id, color_palette[color_id])
			grid_data[pos] = {"type": "terminal", "color": color_id}

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: start_drawing()
		else: stop_drawing()
	if event is InputEventMouseMotion and is_drawing:
		continue_drawing()

func start_drawing():
	var g_pos = local_to_map(get_local_mouse_position())
	if grid_data.get(g_pos) and grid_data[g_pos].type == "terminal":
		current_color_id = grid_data[g_pos].color
		reset_color_path(current_color_id)
		is_drawing = true
		last_pos = g_pos
		create_new_line(color_palette[current_color_id], map_to_local(g_pos))

func reset_color_path(color_id: String):
	completed_colors.erase(color_id)
	if active_lines.has(color_id):
		active_lines[color_id].queue_free()
		active_lines.erase(color_id)
	for pos in grid_data:
		if grid_data[pos] and grid_data[pos].type == "path" and grid_data[pos].color == color_id:
			grid_data[pos] = null

func create_new_line(color: Color, start_pos: Vector2):
	current_line = Line2D.new()
	lines_container.add_child(current_line)
	current_line.default_color = color
	current_line.width = 12
	current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line.add_point(start_pos)
	active_lines[current_color_id] = current_line

func continue_drawing():
	var g_pos = local_to_map(get_local_mouse_position())
	if current_color_id in completed_colors or g_pos == last_pos or not grid_data.has(g_pos): return

	# Interpolação ortogonal (Eixo X depois Y) para evitar diagonais
	var steps = get_orthogonal_path(last_pos, g_pos)
	for step in steps:
		var cell = grid_data[step]
		if cell == null:
			add_step(step)
		elif cell.type == "terminal" and cell.color == current_color_id:
			if step != last_pos:
				add_step(step)
				completed_colors.append(current_color_id)
				is_drawing = false
				check_win_condition()
				break
		else:
			is_drawing = false # Bloqueio de cruzamento
			break

func add_step(pos: Vector2i):
	last_pos = pos
	current_line.add_point(map_to_local(pos))
	if grid_data[pos] == null:
		grid_data[pos] = {"type": "path", "color": current_color_id}

func get_orthogonal_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var p: Array[Vector2i] = []
	var curr = start
	# Resolve primeiro X, depois Y para garantir movimento em "L" e não diagonal
	while curr.x != end.x:
		curr.x += sign(end.x - curr.x)
		p.append(curr)
	while curr.y != end.y:
		curr.y += sign(end.y - curr.y)
		p.append(curr)
	return p

func check_win_condition():
	var all_connected = completed_colors.size() == level_data.size()
	var all_filled = true
	
	for pos in grid_data:
		if grid_data[pos] == null:
			all_filled = false
			break
			
	if all_connected and all_filled:
		print("VITÓRIA: Todas as cores conectadas e grid preenchido!")
	elif all_connected:
		print("Cores conectadas, mas ainda há espaços vazios!")

func stop_drawing():
	is_drawing = false
	current_line = null
