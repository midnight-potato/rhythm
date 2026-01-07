extends Node2D

const LevelButton = preload("res://level_select/level_button.tscn")

var LEVELS = [
	_new_level("Level 0", "res://levels/level0.zip"),
	_new_level("Level 1", "res://levels/level1.zip")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level in LEVELS:
		var button = LevelButton.instantiate()
		button.level_name = level["name"]
		button.level_path = level["path"]
		button.connect("level_selected", func(): _level_selected(level["path"]))
		$CanvasLayer/Panel/MarginContainer/VBoxContainer/HFlowContainer.add_child(button)

func _level_selected(path: String):
	GameState.selected_level = path
	get_tree().change_scene_to_file("res://game/game.tscn")

func _new_level(n: String, p: String) -> Dictionary:
	return {
		'name': n,
		'path': p
	}
