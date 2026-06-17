extends Node2D
# Variável que receberá o texto gigante de fora
@export_multiline var texto_grande : String = ""

# Referência para o nó RichTextLabel
@onready var meu_rich_label : Label = $Label

func _ready():

	
	# Define o texto formatado
	meu_rich_label.text = texto_grande
