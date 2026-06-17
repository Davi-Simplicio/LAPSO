@tool
extends Node2D

# Texto editável no Inspector
@export_multiline var texto_grande: String = "" :
	set(value):
		texto_grande = value
		_atualizar_texto()

@onready var meu_rich_label: Label = $Label


func _ready():
	_atualizar_texto()


func _atualizar_texto():
	if not is_inside_tree():
		return
	if meu_rich_label:
		meu_rich_label.text = texto_grande
