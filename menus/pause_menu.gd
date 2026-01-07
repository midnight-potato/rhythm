extends Node2D

@onready var game = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.visible = visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visibility_changed:
		$CanvasLayer.visible = visible

# unpause
func _on_resume_button_button_up() -> void:
	get_parent().pause()

func _on_restart_button_button_up() -> void:
	game.restart_game()

func _on_menu_button_button_up() -> void:
	game.end_game()
