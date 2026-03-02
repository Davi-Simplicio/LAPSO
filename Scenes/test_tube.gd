extends GridContainer

var last_button: BaseButton = null
var sum = 0

# Mapeia o nome do botão selecionado para o valor numérico
# (Ajuste os nomes conforme o que está no Inspetor do Godot)
var ToNum = {
	"RED": 3,
	"BLUE": 8,
	"YELLOW": 17
}

# Mapeia o resultado da soma para o nome do nó dentro de "Result"
var FromNum = {
	0: "EMPTY",
	3: "RED",
	8: "BLUE",
	17: "YELLOW",
	20: "ORANGE",
	11: "PURPLE",
	25: "GREEN"
}

const READY_COLORS = [20, 11, 25]



func _process(delta: float) -> void:
	var trash = get_node("SpaceTrash")
	if sum > 0:
		trash.get_children()[0].visible = true
	else:
		trash.get_children()[0].visible = false

func _ready() -> void:
	# Busca todos os botões nos "Spaces" para o ButtonGroup
	_update_result_visibility()
	var selection_tubes = find_children("*Opt", "BaseButton", true)
	if selection_tubes.size() > 0:
		var group = selection_tubes[0].button_group
		if group:
			group.pressed.connect(_on_group_pressed)
			last_button = group.get_pressed_button()
			
func _on_group_pressed(button: BaseButton) -> void:
	# 1. Verificamos se o botão clicado é um "filho" do container Result
	# Isso faz com que clicar em RED, BLUE ou PURPLE dentro de Result funcione como o EMPTY
	if button.get_parent().name == "Result" && !READY_COLORS.has(sum):
		if last_button:
			# Limpa o nome para bater com o dicionário (ex: "RedOpt" -> "Red")
			var color_key = last_button.name.replace("Opt", "")
			
			if ToNum.has(color_key):
				sum += ToNum[color_key]
				# 2. Atualiza qual tubo do "Result" deve aparecer agora
				_update_result_visibility()
	# 3. Sempre atualizamos o last_button para o último que clicamos
	last_button = button
	
func _update_result_visibility() -> void:
	# 1. Identifica qual o nome do tubo que deve aparecer baseado na soma
	var target_name = FromNum.get(sum, "EMPTY")
	
	# 2. Acessa o nó "Result" e itera sobre os filhos dele
	var result_container = get_node("Result")
	if result_container:
		for child in result_container.get_children():
			# Se o nome do filho (ex: "Purple") for o alvo, mostramos
			if child.name == target_name:
				child.visible = true
			else:
				child.visible = false


func _on_trash_pressed() -> void:
	sum = 0
	_update_result_visibility()
