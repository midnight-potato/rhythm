extends Node2D

const LevelButton = preload("res://level_select/level_button.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button = LevelButton.instantiate()
	button.level_name = "This is a level"
	button.level_path = "res://levels/level0.zip"
	button.connect("level_selected", func(): _level_selected("res://levels/level0.zip"))
	$CanvasLayer/Panel/MarginContainer/VBoxContainer/HFlowContainer.add_child(button)


func _level_selected(path: String):
	GameState.selected_level = path
	get_tree().change_scene_to_file("res://game/game.tscn")
