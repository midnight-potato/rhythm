extends Node2D

func _ready() -> void:
	visible = true if 'finished' in GameState.stats and GameState.stats['finished'] else false
	$CanvasLayer.visible = visible
	set_stats(GameState.stats)

func _process(_delta: float) -> void:
	if visibility_changed:
		$CanvasLayer.visible = visible

func set_stats(stats: Dictionary):
	if 'score' in stats:
		%scoreAmt.text = str(stats['score'])
	if 'percentage_overall' in stats:
		%percentageAmt.text = str(snapped(stats['percentage_overall'] * 100, 0.01)) + '%\n'
	if 'max_combo' in stats:
		%mcomboAmt.text = str(stats['max_combo'])
	if 'perfects' in stats:
		%perfectAmt.text = str(stats['perfects'])
	if 'combo' in stats:
		%comboAmt.text = str(stats['combo'])
	if 'misses' in stats:
		%missesAmt.text = str(stats['misses'])

func _on_menu_button_button_up() -> void:
	GameState.stats['finished'] = false
	visible = false

func _on_restart_button_button_up() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")
