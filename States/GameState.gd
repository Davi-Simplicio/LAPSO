# GameState.gd
extends Node

var puzzle_relogio_resolvido: bool = false
var puzzle_fios_resolvido: bool = false 
var puzzle_relogio_moderno_resolvido: bool = false

# This dictionary stores simple text keys like "found_post_it" : true
var unlocked_facts: Dictionary = {}

# Call this when you pick up an item or finish a specific dialogue
func unlock_fact(fact_id: String):
	if fact_id != "":
		unlocked_facts[fact_id] = true
		print("Unlocked fact: " + fact_id)

# Call this to check if a button should be visible
func has_fact(fact_id: String) -> bool:
	return unlocked_facts.has(fact_id)
