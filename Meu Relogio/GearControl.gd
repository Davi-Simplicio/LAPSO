## GearControl.gd
extends Area2D

# ─────────────────────────────────────────────
#  REFERÊNCIAS DE NÓS
# ─────────────────────────────────────────────

@onready var hour_hand: Sprite2D = $"../CenterPivot/HourHand"
@onready var minute_hand: Sprite2D = $"../CenterPivot/MinuteHand"
@onready var gear_sprite: Sprite2D = $Gear

# ─────────────────────────────────────────────
#  CONFIGURAÇÕES EXPORTADAS
# ─────────────────────────────────────────────

@export var smoothing: float = 0.15
@export var drag_sensitivity: float = 1.0
@export var gear_rotates_visually: bool = true

# ✅ NOVO: horário alvo (puzzle)
@export var target_hour: int = 12
@export var target_minute: int = 30

# ✅ NOVO: horário inicial
@export var start_hour: int = 12
@export var start_minute: int = 0

# ─────────────────────────────────────────────
#  ESTADO INTERNO
# ─────────────────────────────────────────────

var _is_dragging: bool = false
var _prev_angle: float = 0.0
var _target_minute_rotation: float = 0.0
var _target_hour_rotation: float = 0.0
var _gear_rotation_acc: float = 0.0

# ✅ controle do último horário (para detectar mudança)
var _last_time := { "hours": -1, "minutes": -1 }

# ─────────────────────────────────────────────
#  INICIALIZAÇÃO
# ─────────────────────────────────────────────

func _ready() -> void:
	input_event.connect(_on_input_event)
	set_process_input(true)
	set_process(true)
	input_pickable = true
	
	# Inicializa com horário configurável
	set_time(start_hour, start_minute)
	var t := get_time()
	print("🕐 Horário inicial: %02d:%02d" % [t["hours"], t["minutes"]])

# ─────────────────────────────────────────────
#  PROCESSO PRINCIPAL
# ─────────────────────────────────────────────

func _process(delta: float) -> void:
	if _is_dragging:
		_handle_drag()
		var t := get_time()
		print("🕐 %02d:%02d" % [t["hours"], t["minutes"]])

		# ✅ Detecta quando ENTRA no horário alvo
		if t["hours"] == target_hour and t["minutes"] == target_minute:
			if not (_last_time["hours"] == target_hour and _last_time["minutes"] == target_minute):
				print("✅ A hora original era %02d:%02d" % [target_hour, target_minute])

		# Atualiza último horário
		_last_time = t

	_apply_smooth_rotation(delta)

	if gear_rotates_visually and _is_dragging:
		gear_sprite.rotation = _gear_rotation_acc

# ─────────────────────────────────────────────
#  LÓGICA DE DRAG
# ─────────────────────────────────────────────

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

# ─────────────────────────────────────────────
#  EVENTOS DE INPUT
# ─────────────────────────────────────────────

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_start_drag()
			else:
				_stop_drag()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			if _is_dragging:
				_stop_drag()

# ─────────────────────────────────────────────
#  CONTROLE DE ESTADO
# ─────────────────────────────────────────────

func _start_drag() -> void:
	_is_dragging = true
	
	var dir: Vector2 = get_global_mouse_position() - global_position
	_prev_angle = atan2(dir.y, dir.x)
	
	_target_minute_rotation = minute_hand.rotation
	_target_hour_rotation   = hour_hand.rotation

func _stop_drag() -> void:
	_is_dragging = false

# ─────────────────────────────────────────────
#  UTILITÁRIOS
# ─────────────────────────────────────────────

func _normalize_angle(angle: float) -> float:
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle

# ─────────────────────────────────────────────
#  API PÚBLICA
# ─────────────────────────────────────────────

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
