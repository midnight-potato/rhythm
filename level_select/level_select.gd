extends Node2D

const LevelButton = preload("res://level_select/level_button.tscn")
const theme = preload("res://styles/theme.tres")

var LEVELS = [
	_new_level("Never Gonna Give You Up", "res://levels/rick.zip"),
	_new_level("Dance of the Sugarplum Fairy", "res://levels/sugar.zip")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level in LEVELS:
		var button = LevelButton.instantiate()
		button.level_name = "  " + level["name"] + "  "
		button.level_path = level["path"]
		button.connect("level_selected", func(): _level_selected(level["path"]))
		#button.theme = theme
		$CanvasLayer/Panel/MarginContainer/VBoxContainer/HFlowContainer.add_child(button)

func _level_selected(path: String):
	GameState.selected_level = path
	get_tree().change_scene_to_file("res://game/game.tscn")

func _new_level(n: String, p: String) -> Dictionary:
	return {
		'name': n,
		'path': p
	}

func _on_calibration_button_down() -> void:
	print('test')
	if Input.is_action_pressed("right_click"):
		$calibrationSetMenu.visible = true
	else:
		GameState.selected_level = 'res://levels/calibration.zip'
		get_tree().change_scene_to_file("res://game/calibration.tscn")

func _on_main_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_load_custom_pressed() -> void:
	$CustomFileSelect.select()


func _on_custom_file_selected(path: String) -> void:
	GameState.selected_level = path
	get_tree().change_scene_to_file("res://game/game.tscn")
