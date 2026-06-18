## Clock.gd — attach no nó raiz Clock (Node2D)
## Configurado para o background original do relógio cuco (1344x768)

extends Node2D

signal puzzle_fechado

func _ready() -> void:
	var screen := get_viewport_rect().size
	position = screen / 2.0

	var bg          := $background           as Sprite2D
	var pivot       := $CenterPivot            as Node2D
	var hour        := $CenterPivot/HourHand   as Sprite2D
	var minute      := $CenterPivot/MinuteHand as Sprite2D
	var gear_area   := $GearControl            as Area2D
	var gear_sprite := $GearControl/Gear       as Sprite2D

	bg.position = Vector2.ZERO
	bg.centered = true

	var tex := Vector2(1344.0, 768.0)
	if bg.texture:
		tex = Vector2(bg.texture.get_width(), bg.texture.get_height())

	# Centro do mostrador
	var dial_x := 10.0
	var dial_y := tex.y * 0.445 - tex.y * 0.50
	pivot.position = Vector2(dial_x, dial_y)

	# ── Ponteiro de Horas (32x120px, pivot na base) ───────────────────────
	var hour_w := 15.0
	var hour_h := 160.0
	if hour.texture:
		hour_w = float(hour.texture.get_width())
		hour_h = float(hour.texture.get_height())

	hour.centered = false
	hour.position = Vector2.ZERO
	hour.offset = Vector2(-hour_w / 2.0, -hour_h + 14.0)

	# ── Ponteiro de Minutos (22x160px, pivot na base) ─────────────────────
	var min_w := 22.0
	var min_h := 160.0
	if minute.texture:
		min_w = float(minute.texture.get_width())
		min_h = float(minute.texture.get_height())

	minute.centered = false
	minute.position = Vector2.ZERO
	minute.offset = Vector2(-min_w / 2.0, -min_h + 12.0)

	# ── Engrenagem ────────────────────────────────────────────────────────
	var gear_x := tex.x * 0.56 - tex.x * 0.50
	var gear_y := tex.y * 0.70 - tex.y * 0.50
	gear_area.position = Vector2(gear_x, gear_y)

	gear_sprite.position = Vector2.ZERO
	gear_sprite.centered = true

	call_deferred("_set_initial_time")

func _set_initial_time() -> void:
	var gear_area := $GearControl
	if gear_area.has_method(&"set_time"):
		gear_area.call(&"set_time", 10, 10)

func notificar_fechamento() -> void:
	emit_signal("puzzle_fechado")
	queue_free()
