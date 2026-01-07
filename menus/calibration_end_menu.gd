extends Node2D

func _ready() -> void:
	visible = true if 'calibration' in GameState.stats and GameState.stats['calibration'] else false
	$CanvasLayer.visible = visible
	set_stats(GameState.stats)

func _process(_delta: float) -> void:
	if visibility_changed:
		$CanvasLayer.visible = visible

func set_stats(stats: Dictionary):
	if 'avg_offset' in stats:
		%offsetAmt.text = str(snapped(stats['avg_offset'] * 1000, 0.001))

func _on_menu_button_button_up() -> void:
	GameState.stats['calibration'] = false
	GameState.input_offset = -GameState.stats['avg_offset']
	print('new input offset: ', GameState.input_offset, 's')
	visible = false

func _on_cancel_button_button_up() -> void:
	GameState.stats['calibration'] = false
	visible = false
