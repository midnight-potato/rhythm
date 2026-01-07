extends Node

var selected_level: String
# score brackets
var tiers: Array[Dictionary] = [
	_new_bracket("Perfect", 0.016, 100, _rgb_to_01(216, 184, 255), "res://assets/hitmarker_perfect.png"),
	_new_bracket("Great", 0.037, 67, _rgb_to_01(189, 213, 255), "res://assets/hitmarker_great.png"),
	_new_bracket("Good", 0.055, 33, _rgb_to_01(200, 255, 229), "res://assets/hitmarker_good.png"),
	_new_bracket("Okay", 0.095, 12, _rgb_to_01(255, 245, 189), "res://assets/hitmarker_okay.png"),
	_new_bracket("Miss", 0.250, 0, _rgb_to_01(210, 210, 210), "res://assets/hitmarker_miss.png")
]
var stats: Dictionary
var input_offset: float = 0.0

func _rgb_to_01(r: float, g: float, b: float) -> Vector3:
	return Vector3(r/255, g/255, b/255)

func _new_bracket(n: String, t: float, s: int, c: Vector3, h: String) -> Dictionary:
	return {
		"tier": n,
		"threshold": t,
		"score": s,
		"color": c,
		"hitmarker": h
	}
