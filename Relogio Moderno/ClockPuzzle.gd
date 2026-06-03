extends Node2D

signal puzzle_fechado

var hora: int = 0
var minuto: int = 0
var hora_alvo: int = 12
var minuto_alvo: int = 30
var puzzle_resolvido: bool = false

@onready var label_horario: Label = $LabelHorario
@onready var btn_hora_mais: Button = $BotaoHora/BtnHoraMais
@onready var btn_hora_menos: Button = $BotaoHora/BtnHoraMenos
@onready var btn_min_mais: Button = $BotaoMinuto/BtnMinMais
@onready var btn_min_menos: Button = $BotaoMinuto/BtnMinMenos
@onready var animacao: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	btn_hora_mais.pressed.connect(_on_hora_mais_pressed)
	btn_hora_menos.pressed.connect(_on_hora_menos_pressed)
	btn_min_mais.pressed.connect(_on_min_mais_pressed)
	btn_min_menos.pressed.connect(_on_min_menos_pressed)
	_atualizar_display()
	print("=== Clock Puzzle iniciado! Horário alvo: %02d:%02d ===" % [hora_alvo, minuto_alvo])

# INTERRUPTOR DO ESC: Alterado para _input para garantir prioridade de leitura
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not puzzle_resolvido:
		emit_signal("puzzle_fechado")
		get_viewport().set_input_as_handled() # Evita que o ESC clique em algo atrás

func _on_hora_mais_pressed() -> void:
	hora = (hora + 1) % 24
	_atualizar_display()
	_verificar_puzzle()

func _on_hora_menos_pressed() -> void:
	hora = (hora - 1 + 24) % 24
	_atualizar_display()
	_verificar_puzzle()

func _on_min_mais_pressed() -> void:
	minuto = (minuto + 1) % 60
	_atualizar_display()
	_verificar_puzzle()

func _on_min_menos_pressed() -> void:
	minuto = (minuto - 1 + 60) % 60
	_atualizar_display()
	_verificar_puzzle()

func _atualizar_display() -> void:
	var texto: String = "%02d:%02d" % [hora, minuto]
	label_horario.text = texto

func _verificar_puzzle() -> void:
	var acertou: bool = (hora == hora_alvo and minuto == minuto_alvo)
	if acertou and not puzzle_resolvido:
		puzzle_resolvido = true
		_set_botoes_ativos(false)
		print("✅ Puzzle resolvido!")
		
		if animacao and animacao.has_animation("sucesso"):
			animacao.play("sucesso")
			
		if has_node("/root/GameState"):
			get_node("/root/GameState").puzzle_relogio_moderno_resolvido = true
			
		# Espera 2 segundos mostrando o acerto e fecha automaticamente
		await get_tree().create_timer(2.0).timeout
		emit_signal("puzzle_fechado")

func _set_botoes_ativos(ativo: bool) -> void:
	btn_hora_mais.disabled = not ativo
	btn_hora_menos.disabled = not ativo
	btn_min_mais.disabled = not ativo
	btn_min_menos.disabled = not ativo

func reiniciar() -> void:
	hora = 0
	minuto = 0
	puzzle_resolvido = false
	_set_botoes_ativos(true)
	_atualizar_display()

func definir_alvo(h: int, m: int) -> void:
	hora_alvo = clamp(h, 0, 23)
	minuto_alvo = clamp(m, 0, 59)
	puzzle_resolvido = false
