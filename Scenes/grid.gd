extends TileMapLayer

@export var grid_width: int = 16
@export var grid_height: int = 16
@export var tile_atlas_pos: Vector2i = Vector2i(0, 0) # Coordenada do tile na sua imagem
@export var source_id: int = 0 # ID da sua fonte de tiles (geralmente 0)

func _ready():
	generate_grid()

func generate_grid():
	clear()
	
	# 1. Desenha o grid
	for x in range(grid_width):
		for y in range(grid_height):
			set_cell(Vector2i(x, y), source_id, tile_atlas_pos)
	
	# 2. Calcula o tamanho total do grid em pixels
	# Multiplicamos o número de colunas/linhas pelo tamanho do tile (16px no seu caso)
	#var tile_size = tile_set.tile_size
	#var grid_total_pixel_size = Vector2(grid_width, grid_height) * Vector2(tile_size)
	#
	## Centraliza o grid em relação ao nó pai (a cena)
	## Se a sua chapa está no (0,0), isso vai colocar o grid no centro dela.
	#self.position = -grid_total_pixel_size / 2
