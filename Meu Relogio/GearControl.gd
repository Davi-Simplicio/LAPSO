extends Area2D

@onready var hour_hand: Sprite2D = $"../CenterPivot/HourHand"
@onready var minute_hand: Sprite2D = $"../CenterPivot/MinuteHand"
@onready var gear_sprite: Sprite2D = $Gear
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var smoothing: float = 0.15
@export var drag_sensitivity: float = 1.0
@export var gear_rotates_visually: bool = true

@export var target_hour: int = 16
@export var target_minute: int = 15

@export var start_hour: int = 12
@export var start_minute: int = 0

var _is_dragging: bool = false
var _prev_angle: float = 0.0
var _target_minute_rotation: float = 0.0
var _target_hour_rotation: float = 0.0
var _gear_rotation_acc: float = 0.0
var _last_time := { "hours": -1, "minutes": -1 }
var _tempo_no_alvo: float = 0.0

var puzzle_resolvido: bool = false
var _saindo: bool = false

func _ready() -> void:
	input_pickable = false
	set_process_input(true)
	set_process(true)

	puzzle_resolvido = false
	_saindo = false
	_last_time = { "hours": -1, "minutes": -1 }
	_tempo_no_alvo = 0.0

	set_time(start_hour, start_minute)
	var t := get_time()
	print("Base: Horário inicial configurado para %02d:%02d" % [t["hours"], t["minutes"]])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		sair_do_puzzle()
		return

	if _is_dragging and not puzzle_resolvido:
		_handle_drag()
		var t := get_time()

		if t["hours"] == target_hour and t["minutes"] == target_minute:
			_tempo_no_alvo += delta
			if _tempo_no_alvo >= 2.0:
				puzzle_resolvido = true
				print("✅ Puzzle resolvido! %02d:%02d" % [target_hour, target_minute])
				_ao_resolver()
		else:
			_tempo_no_alvo = 0.0

		_last_time = t

	_apply_smooth_rotation(delta)

	if gear_rotates_visually and _is_dragging and not puzzle_resolvido:
		gear_sprite.rotation = _gear_rotation_acc

# FORÇA BRUTA: Intercepta o clique no nível mais alto do motor da Godot, antes de qualquer outro nó
func _input(event: InputEvent) -> void:
	if puzzle_resolvido:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				if _is_mouse_over_gear():
					_start_drag()
			else:
				if _is_dragging:
					_stop_drag()

func _is_mouse_over_gear() -> bool:
	if not is_inside_tree() or not is_visible_in_tree():
		return false
		
	# Distância direta global do mouse até o centro da engrenagem
	var dist = global_position.distance_to(get_global_mouse_position())
	
	# Usando um raio fixo generoso baseado no tamanho padrão da engrenagem (65 pixels)
	# Isso ignora completamente se houver colisores ou mapas na frente
	if collision_shape and collision_shape.shape is CircleShape2D:
		return dist <= (collision_shape.shape as CircleShape2D).radius
		
	return dist < 65.0

func _ao_resolver() -> void:
	await get_tree().create_timer(1.0).timeout
	sair_do_puzzle()

func sair_do_puzzle() -> void:
	if _saindo:
		return
	_saindo = true

	if puzzle_resolvido:
		if has_node("/root/GameState"):
			get_node("/root/GameState").puzzle_relogio_resolvido = true

	var pai = get_parent()
	if is_instance_valid(pai) and pai.has_method("notificar_fechamento"):
		pai.notificar_fechamento()

func _handle_drag() -> void:
	var gear_center: Vector2 = global_position
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dir: Vector2 = mouse_pos - gear_center

	var current_angle: float = atan2(dir.y, dir.x)
	var delta_angle: float = _normalize_angle(current_angle - _prev_angle)

	delta_angle *= drag_sensitivity

	_target_minute_rotation += delta_angle
	_target_hour_rotation   += delta_angle / 12.0

	_gear_rotation_acc -= delta_angle

	_prev_angle = current_angle

func _apply_smooth_rotation(delta: float) -> void:
	if smoothing > 0.0:
		var t: float = 1.0 - pow(smoothing, delta * 60.0)
		minute_hand.rotation = lerp_angle(minute_hand.rotation, _target_minute_rotation, t)
		hour_hand.rotation   = lerp_angle(hour_hand.rotation,   _target_hour_rotation,   t)
	else:
		minute_hand.rotation = _target_minute_rotation
		hour_hand.rotation   = _target_hour_rotation

func _start_drag() -> void:
	_is_dragging = true
	var dir: Vector2 = get_global_mouse_position() - global_position
	_prev_angle = atan2(dir.y, dir.x)
	_target_minute_rotation = minute_hand.rotation
	_target_hour_rotation   = hour_hand.rotation

func _stop_drag() -> void:
	_is_dragging = false

func _normalize_angle(angle: float) -> float:
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle

func set_time(hours: int, minutes: int) -> void:
	var min_angle: float  = deg_to_rad(minutes * 6.0)
	var hour_angle: float = deg_to_rad(hours * 30.0 + minutes * 0.5)

	_target_minute_rotation = min_angle
	_target_hour_rotation   = hour_angle
	minute_hand.rotation    = min_angle
	hour_hand.rotation      = hour_angle

func get_time() -> Dictionary:
	var min_deg: float = fmod(rad_to_deg(minute_hand.rotation) + 360.0, 360.0)
	var minutes: int = int(min_deg / 6.0) % 60

	var hour_deg: float = fmod(rad_to_deg(hour_hand.rotation) + 360.0, 360.0)
	var hours: int = int(hour_deg / 30.0) % 12
	if hours == 0:
		hours = 12

	return { "hours": hours, "minutes": minutes }

func reiniciar() -> void:
	puzzle_resolvido = false
	_last_time = { "hours": -1, "minutes": -1 }
	_saindo = false
	_tempo_no_alvo = 0.0
	set_time(start_hour, start_minute)
	print("🔄 Puzzle reiniciado")
