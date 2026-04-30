extends Node2D

var color_id: String = ""
var color_value: Color

func setup(id: String, val: Color):
	color_id = id
	color_value = val
	
	# O segredo é garantir que o nó existe. 
	# Verifique se o nome na sua árvore de cena é exatamente 'Sprite2D'
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = val
	else:
		# Se cair aqui, é porque o nome do nó na sua cena TerminalFlowFree.tscn é diferente
		print("Erro: Nó Sprite2D não encontrado no Terminal!")
