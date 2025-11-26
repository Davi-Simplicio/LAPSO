# NPCResource.gd
class_name NPCResource
extends Resource

@export var npc_name: String = "Character Name"
@export var portrait: Texture2D
@export_multiline var greeting_text: String = "Hello, detective."

# This is where we will drag-and-drop our topics
@export var topics: Array[DialogueTopic] = []
