extends Control

var weight = 0
var weights = []

var Cristal = null
var Balanca = null
var BalancaDireita = null
var BalancaEsquerda = null
var WeightGroup = null

var direita = false
var esquerda = false
var centro = true

const final_pos = {"x": -15, "y":40}
const final_weight = 35

const AlignCristalYBottom = 6.5
const AlignCristalYTop = -3
const AlignCristalXBottom = 0.5
const AlignCristalXTop = 0.5

const AlignWGYBottom = 7
const AlignWGYTop = -2
const AlignWGXBottom = -0.5
const AlignWGXTop = -0.5

const originalYWGPos = 23
const originalXWGPos = 13
const originalYCristalPos = 26
const originalXCristalPos = 42


func _ready() -> void:
	Cristal = find_child("Cristal")
	WeightGroup = find_child("WeightGroup")
	Balanca = get_node("../Balança")
	BalancaDireita = get_node("../Balança-Direita")
	BalancaEsquerda = get_node("../Balança-Esquerda")
	
	# Loops through all children of 'Control'
	for button in get_children():
		if button is TextureButton:
			button.pressed.connect(_update_weight_visibility.bind(button))
		if button is Control:
			for button2 in button.get_children():
				if button2 is TextureButton:
					button2.pressed.connect(_update_weight_visibility.bind(button2))


func sum (a:int, b:int) -> int:
	return a + b
	
func transform_weights(w: String) -> int: 
	return w.split("-")[0].to_int()
	
func _update_cristal() -> void:
	var weightsInt = weights.map(transform_weights)
	var sum_list = weightsInt.reduce(sum, 0)
	
	centro = weight == sum_list
	Balanca.visible = centro
	direita =  weight > sum_list
	BalancaDireita.visible = direita
	esquerda = weight < sum_list
	BalancaEsquerda.visible = esquerda
	
	if weight == final_weight:
		Cristal.position.y = (originalYCristalPos + AlignCristalYBottom) if direita else (originalYCristalPos + AlignCristalYTop) if esquerda else (originalYCristalPos)
		Cristal.position.x = (originalXCristalPos + AlignCristalXBottom) if direita else (originalXCristalPos + AlignCristalXTop) if esquerda else (originalXCristalPos)
	else:
		Cristal.position.y = final_pos.y
		Cristal.position.x = final_pos.x
		
	if WeightGroup:
		WeightGroup.position.y = (originalYWGPos + AlignWGYTop) if direita else (originalYWGPos + AlignWGYBottom) if esquerda else (originalYWGPos)
		WeightGroup.position.x = (originalXWGPos + AlignWGXTop) if direita else (originalXWGPos + AlignWGXBottom) if esquerda else (originalXWGPos)
	

func _update_weight_visibility(button:BaseButton) -> void:
	if button.name.ends_with("1"):
		weights.append(button.name.split("_")[1].split("-")[0])
	else:
		weights.erase(button.name.split("_")[1].split("-")[0])
	print(weights)
	button.visible = false;
	var rplc1 = "-1" if button.name.ends_with("1") else "-2"
	var rplc2 = "-2" if button.name.ends_with("1") else "-1"
	find_child(button.name.replace(rplc1, rplc2)).visible = true
	_update_cristal()
	
func _on_get_cristal_pressed() -> void:
	weight = final_weight if weight == 0 else 0
	_update_cristal()
	
