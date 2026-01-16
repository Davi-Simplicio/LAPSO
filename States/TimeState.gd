class_name TimeState
extends Resource

@export_group("Visuals")
@export var state_name: String = "Normal"
@export var overlay_color: Color = Color("#1a1c3a") # For CanvasModulate
@export var light_energy_multiplier: float = 1.0

@export_group("Decorations")
# We use strings to know which Node groups to turn ON
@export var active_decor_group: String = "Decor_Normal"
