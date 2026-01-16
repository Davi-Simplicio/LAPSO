class_name DocumentResource
extends Resource

@export_group("Visuals")
@export var full_image: Texture2D  # The big version you read
@export var icon: Texture2D        # Small version for inventory (optional)
@export var doc_name: String = "Mysterious Note"

@export_group("Game Logic")
@export var fact_id_to_unlock: String = "" # e.g. "found_secret_plans"
