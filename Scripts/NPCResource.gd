class_name NPCResource
extends Resource

# --- SECTION 1: IDENTITY & DIALOGUE (The Brain) ---
@export_group("Identity")
@export var npc_name: String = "Character Name"
@export var portrait: Texture2D
@export_multiline var greeting_text: String = "Hello."

# THIS IS THE MISSING VARIABLE
@export var topics: Array[DialogueTopic] = [] 

# --- SECTION 2: VISUALS (The Body) ---
@export_group("Visuals")
@export var sprite_sheet: Texture2D  # The texture file
@export var h_frames: int = 4        # Columns
@export var v_frames: int = 4        # Rows

@export_group("Behavior")
@export var initial_animation: String = "Idle_Down"
