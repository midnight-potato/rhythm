extends Node

var selected_level: String
# score brackets
var tiers: Array[Dictionary] = [
	_new_bracket("Perfect", 0.016, 100),
	_new_bracket("Great", 0.037, 67),
	_new_bracket("Good", 0.055, 33),
	_new_bracket("Okay", 0.095, 12)
]
var stats: Dictionary

func _new_bracket(n: String, t: float, s: int) -> Dictionary:
	return {
		"tier": n,
		"threshold": t,
		"score": s
	}
