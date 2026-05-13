extends Node2D

var hora: int = 0
var minuto: int = 0
var hora_alvo: int = 12
var minuto_alvo: int = 30
var puzzle_resolvido: bool = false

@onready var label_horario: Label  = $LabelHorario
@onready var label_sucesso: Label  = $LabelSucesso
@onready var label_alvo: Label     = $LabelAlvo
@onready var btn_hora_mais: Button  = $BotaoHora/BtnHoraMais
@onready var btn_hora_menos: Button = $BotaoHora/BtnHoraMenos
@onready var btn_min_mais: Button   = $BotaoMinuto/BtnMinMais
@onready var btn_min_menos: Button  = $BotaoMinuto/BtnMinMenos
@onready var animacao: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	btn_hora_mais.pressed.connect(_on_hora_mais_pressed)
	btn_hora_menos.pressed.connect(_on_hora_menos_pressed)
	btn_min_mais.pressed.connect(_on_min_mais_pressed)
	btn_min_menos.pressed.connect(_on_min_menos_pressed)

	label_alvo.text = "Acerte: %02d:%02d" % [hora_alvo, minuto_alvo]
	label_sucesso.visible = false

	_atualizar_display()

	print("=== Clock Puzzle iniciado! Horário alvo: %02d:%02d ===" % [hora_alvo, minuto_alvo])


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
	print("Hora atual: " + texto)


func _verificar_puzzle() -> void:
	var acertou: bool = (hora == hora_alvo and minuto == minuto_alvo)

	# Se acabou de acertar
	if acertou and not puzzle_resolvido:
		puzzle_resolvido = true
		label_sucesso.visible = true
		print("✅ Puzzle resolvido! Horário correto: %02d:%02d" % [hora_alvo, minuto_alvo])

		if animacao and animacao.has_animation("sucesso"):
			animacao.play("sucesso")

	# Se estava correto e saiu do horário
	elif not acertou and puzzle_resolvido:
		puzzle_resolvido = false
		label_sucesso.visible = false
		print("❌ Saiu do horário correto")


func reiniciar() -> void:
	hora = 0
	minuto = 0
	puzzle_resolvido = false
	label_sucesso.visible = false
	_atualizar_display()


func definir_alvo(h: int, m: int) -> void:
	hora_alvo = clamp(h, 0, 23)
	minuto_alvo = clamp(m, 0, 59)

	label_alvo.text = "Acerte: %02d:%02d" % [hora_alvo, minuto_alvo]

	puzzle_resolvido = false
	label_sucesso.visible = false
