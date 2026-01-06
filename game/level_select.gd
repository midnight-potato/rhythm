extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_0_pressed() -> void:
	GameState.selected_level = "res://levels/level0.zip"
	get_tree().change_scene_to_file("res://game/game.tscn")
