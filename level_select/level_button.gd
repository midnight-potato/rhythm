extends PanelContainer

@export var level_name: String
@export var 	level_path: String

signal level_selected()


func _ready() -> void:
	$Label.text = level_name


func _on_button_pressed() -> void:
	level_selected.emit()
