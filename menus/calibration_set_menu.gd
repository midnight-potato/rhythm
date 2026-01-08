extends Node2D

func _ready() -> void:
	visible = false
	$CanvasLayer.visible = visible

func _process(_delta: float) -> void:
	if visibility_changed:
		$CanvasLayer.visible = visible

func _on_ok_button_button_up() -> void:
	if %offsetAmt.text.is_valid_float():
		GameState.input_offset = %offsetAmt.text.to_float() / 1000.0
		print('new input offset: ', GameState.input_offset, "s")
		visible = false

func _on_cancel_button_button_up() -> void:
	visible = false
