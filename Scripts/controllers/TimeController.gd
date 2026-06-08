extends Node2D

# Substitua pelo caminho correto até o node da miniatura do elevador no seu mapa
@onready var miniatura_elevador = $hotel_doors/Elevator
var Past = null;
var Present = null;
var Future = null;

func _ready():
	# Conecta o sinal da miniatura à função local do mapa
	
	Past = get_node("Past");
	Present = get_node("Present");
	Future = get_node("Future");
	
	
		
	miniatura_elevador.map_update_requested.connect(_on_map_update_requested)
	
func _on_map_update_requested(action_data: int):
	Past.visible = action_data == 1
	Present.visible = action_data == 2
	Future.visible = action_data == 3
	
	Past.get_node("hotel_decoration").collision_enabled = Past.visible == true
	Present.get_node("hotel_decoration").collision_enabled = Present.visible == true
	Future.get_node("hotel_decoration").collision_enabled = Future.visible == true
	Past.get_node("hotel_decoration_details").collision_enabled = Past.visible == true
	Present.get_node("hotel_decoration_details").collision_enabled = Present.visible == true
	Future.get_node("hotel_decoration_details").collision_enabled = Future.visible == true
	
	Past.process_mode = Node.PROCESS_MODE_INHERIT if action_data == 1 else Node.PROCESS_MODE_DISABLED
	Present.process_mode = Node.PROCESS_MODE_INHERIT if action_data == 2 else Node.PROCESS_MODE_DISABLED
	Future.process_mode = Node.PROCESS_MODE_INHERIT if action_data == 3 else Node.PROCESS_MODE_DISABLED
