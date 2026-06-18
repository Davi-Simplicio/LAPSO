extends Node
## MainMenu — Hotel Delacroix
## Chame com: get_tree().change_scene_to_file("res://HotelScreens/main_menu.tscn")
## Ou conecte o sinal: menu.start_game.connect(func(): get_tree().change_scene_to_file("res://sua_cena.tscn"))

signal start_game

@onready var _fade           : ColorRect      = $FadeLayer/FadeRect
@onready var _clock_panel    : ColorRect      = $UI/Root/Margin/VBox/ClockPanel
@onready var _btn_jogar      : Button         = $UI/Root/Margin/VBox/Buttons/BtnJogar
@onready var _btn_credits    : Button         = $UI/Root/Margin/VBox/Buttons/BtnCreditos
@onready var _credits_layer  : CanvasLayer    = $CreditsLayer
@onready var _bg_dim         : ColorRect      = $CreditsLayer/BgDim
@onready var _credits_panel  : PanelContainer = $CreditsLayer/Panel
@onready var _btn_fechar     : Button         = $CreditsLayer/Panel/VBox/BtnFechar

var _clock_h : float = 0.0
var _clock_m : float = 0.0

func _ready() -> void:
	_fade.color             = Color(0, 0, 0, 1)
	_credits_layer.visible  = false
	_bg_dim.color           = Color(0, 0, 0, 0)
	_credits_panel.modulate = Color(1, 1, 1, 0)

	_clock_panel.draw.connect(_draw_clock)
	_btn_jogar.pressed.connect(_jogar)
	_btn_credits.pressed.connect(_abrir_creditos)
	_btn_fechar.pressed.connect(_fechar_creditos)

	await get_tree().process_frame
	_clock_panel.pivot_offset = _clock_panel.size * 0.5

	var tw := create_tween()
	tw.tween_property(_fade, "color", Color(0, 0, 0, 0), 1.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(_dt: float) -> void:
	var t  := Time.get_time_dict_from_system()
	_clock_h = (TAU / 12.0) * (fmod(float(t["hour"]), 12.0) + t["minute"] / 60.0)
	_clock_m = (TAU / 60.0) * (t["minute"] + t["second"] / 60.0)
	_clock_panel.queue_redraw()

func _draw_clock() -> void:
	var C  := Vector2(_clock_panel.size.x * 0.5, _clock_panel.size.y * 0.5)
	const R := 42.0
	_clock_panel.draw_circle(C, R + 5, Color(0.039, 0.020, 0.008))
	_clock_panel.draw_arc(C, R + 5, 0, TAU, 64, Color(0.541, 0.353, 0.094), 2, true)
	_clock_panel.draw_circle(C, R, Color(0.090, 0.051, 0.020))
	_clock_panel.draw_arc(C, R, 0, TAU, 64, Color(0.353, 0.220, 0.063, 0.8), 1, true)
	for i in 12:
		var a := (TAU / 12.0) * i - PI * 0.5
		var d := Vector2(cos(a), sin(a))
		_clock_panel.draw_line(C + d * R * 0.80, C + d * R * 0.95,
			Color(0.784, 0.565, 0.165, 0.9), 2.5 if i % 3 == 0 else 1.0, true)
	var hd := Vector2(sin(_clock_h), -cos(_clock_h))
	_clock_panel.draw_line(C - hd * 5, C + hd * R * 0.55, Color(0.784, 0.565, 0.165), 3.5, true)
	var md := Vector2(sin(_clock_m), -cos(_clock_m))
	_clock_panel.draw_line(C - md * 7, C + md * R * 0.78, Color(0.910, 0.773, 0.416), 2.5, true)
	_clock_panel.draw_circle(C, 5, Color(0.541, 0.353, 0.094))
	_clock_panel.draw_circle(C, 2.5, Color(0.910, 0.773, 0.416))

func _jogar() -> void:
	_btn_jogar.disabled   = true
	_btn_credits.disabled = true
	
	var tw := create_tween()
	tw.tween_property(_fade, "color", Color(0, 0, 0, 1), 0.9)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	# Call a separate function when the fade finishes
	tw.finished.connect(_on_fade_finished)


func _on_fade_finished() -> void:
	emit_signal("start_game")
	
	# Reset GameState variables
	get_node("/root/GameState").puzzle_relogio_resolvido = false
	get_node("/root/GameState").puzzle_fios_resolvido = false
	get_node("/root/GameState").puzzle_flow_free_resolvido = false
	get_node("/root/GameState").puzzle_relogio_moderno_resolvido = false
	get_node("/root/GameState").unlocked_facts = {}
	
	# Reset Player and Mapa positions
	# Change Vector2(0, 0) to your exact starting coordinates
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(38, 10)
		
	var mapa = get_tree().get_first_node_in_group("mapa")
	if mapa:
		mapa.global_position = Vector2(0,0)
			
	# Safely delete the MainMenu now that the fade is done
	queue_free()



func _abrir_creditos() -> void:
	_credits_layer.visible = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_bg_dim, "color", Color(0, 0, 0, 0.75), 0.35)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_credits_panel, "modulate", Color(1, 1, 1, 1), 0.35)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _fechar_creditos() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_bg_dim, "color", Color(0, 0, 0, 0), 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(_credits_panel, "modulate", Color(1, 1, 1, 0), 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	_credits_layer.visible = false
