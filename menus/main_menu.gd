extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	var t = create_tween()
	t.set_parallel(true)
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
