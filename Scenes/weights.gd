extends Control

var weight = 0
var weights = []

var Cristal = null
var ClawClosed = null
var ClawOpen = null
var Cron = null
var CronText = null
var CronOn = null
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

var isInClaw = false
var isCronOn = false
var is_dropping = false
var time_elapsed = 0.0 # Use float for precise chronometer tracking
var seconds = 0
var milliseconds = 0

func _process(delta: float) -> void:
	if is_dropping:
		time_elapsed += delta
		seconds = int(time_elapsed)
		# fmod gets the decimal remainder of the time_elapsed, multiplied by 1000 for milliseconds
		milliseconds = int(fmod(time_elapsed, 1.0) * 1000) 
		CronText.text = str(seconds) + "." + str(milliseconds)
		# Example of how to format your Label later:
		# $YourLabel.text = "%02d:%03d" % [seconds, milliseconds]
		
func _ready() -> void:
	Cristal = find_child("Cristal")
	Cron = find_child("Cron")
	CronText = find_child("CronText")
	CronOn = find_child("CronOn")
	ClawClosed = find_child("ClawClosed")
	ClawOpen = find_child("ClawOpen")
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
	elif isInClaw:
		Cristal.position.x = -29.5
		Cristal.position.y = -1.5
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
	
func _update_cron_on() -> void:
	Cron.visible = !isCronOn
	CronOn.visible = isCronOn
	
func _on_get_cristal_pressed() -> void:
	weight = final_weight if weight == 0 else 0
	isInClaw = false
	_update_cristal()
	
func _on_get_cristal_claw_pressed() -> void:
	weight = 0
	if !isInClaw:
		isCronOn = false
		_update_cron_on()
	ClawClosed.visible = !isInClaw && !isCronOn
	ClawOpen.visible = isInClaw || isCronOn
	isInClaw = !isInClaw
	_update_cristal()
	
	
func _end_drop_cristal() -> void:
	is_dropping = false
	isCronOn = false
	_update_cron_on()
	
func _drop_cristal() -> void:
	if !isCronOn || !isInClaw:
		return
		
	is_dropping = true
	time_elapsed = 0.0 

	var tween = create_tween()
	
	# A very short duration (e.g., 0.3 or 0.4 seconds) will make it drop fast instantly.
	var drop_duration = 0.35 
	
	# TRANS_LINEAR ensures the speed is exactly the same from the first pixel to the last.
	tween.tween_property(Cristal, "position:y", 31.0, drop_duration) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN) # EASE type doesn't affect LINEAR, but it's fine to leave it.
		
	tween.finished.connect(_end_drop_cristal)
	
	
func _on_cron_change_pressed() -> void:
	ClawClosed.visible = isInClaw && isCronOn
	ClawOpen.visible = !isInClaw || !isCronOn
	isCronOn = !isCronOn
	_update_cron_on()
	_drop_cristal()
	pass;
