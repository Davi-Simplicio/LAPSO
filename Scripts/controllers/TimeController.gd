extends Node2D

@export var state_past: TimeState
@export var state_present: TimeState
@export var state_future: TimeState

@onready var era_nodes = [$Past, $Present, $Future]
@onready var timeline_states = [state_past, state_present, state_future]

var current_index = 0

func _ready():
	apply_state_by_index(current_index)

func _input(event):
	if event.is_action_pressed("time_travel") and GameState.has_fact("time_travel"):
		cycle_time()

func cycle_time():
	current_index += 1
	if current_index >= timeline_states.size():
		current_index = 0
	
	apply_state_by_index(current_index)

func apply_state_by_index(index: int):
	var active_node = era_nodes[index]
	for node in era_nodes:
		if node == active_node:
			toggle_era(node, true)
		else:
			toggle_era(node, false)

func toggle_era(node: Node2D, is_active: bool):
	node.visible = is_active
	if is_active:
		node.process_mode = Node.PROCESS_MODE_INHERIT
		print("Enabled: ", node.name)
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED
		print("Disabled: ", node.name)
	var tilemaps = node.find_children("*", "TileMapLayer", true, false)
	for layer in tilemaps:
		layer.collision_enabled = is_active
		layer.enabled = is_active

func change_time_by_floor(floor_number: int):
	match floor_number:
		0:  # Hall = Present (index 1)
			current_index = 1
		1:  # 1st Floor = Past (index 0)
			current_index = 0
		2:  # 2nd Floor = Future (index 2)
			current_index = 2
		3:  # 3rd Floor = Present (index 1)
			current_index = 1
			
	apply_state_by_index(current_index)
