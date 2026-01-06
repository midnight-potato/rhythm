extends Node

var selected_level: String
var score: float = 0.0
# score brackets
var tiers: Array[Dictionary] = [
	_new_bracket("Perfect", 0.035, 10.0),
	_new_bracket("Great", 0.075, 6.7),
	_new_bracket("Good", 0.110, 3.3),
	_new_bracket("Okay", 0.190, 1.2)
]

func _new_bracket(n: String, t: float, s: float) -> Dictionary:
	return {
		"tier": n,
		"threshold": t,
		"score": s
	}
