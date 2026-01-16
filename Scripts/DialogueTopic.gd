# DialogueTopic.gd
class_name DialogueTopic
extends Resource

@export var button_label: String = "Ask about..."
# If this is empty, the button always shows. 
# If you type "found_post_it", the button only shows if GameState has that fact.
@export var required_fact_id: String = "" 

@export_multiline var lines: Array[String] = ["Player: ...", "NPC: ..."]
