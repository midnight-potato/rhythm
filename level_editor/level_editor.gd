extends Control

var bpm: int = 60
var notes: Array[Dictionary] = []
var play_pos := 0.0
var level_name := "unknown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicDialog.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	play_pos = $MusicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix()
	%Notes.position.x = get_viewport().get_visible_rect().size.x / 2 - play_pos * 200
	%PlayButton.text = "▶️" if not $MusicPlayer.playing or $MusicPlayer.stream_paused else "⏸️"
	%TitleLabel.text = "Editing level: " + level_name
	%BPMLabel.text = "BPM: " + str(bpm)

	if Input.is_action_just_pressed("hit"):
		# add a note
		print("add note")


func _on_music_dialog_canceled() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_music_dialog_file_selected(path: String) -> void:
	var stream = AudioStreamMP3.load_from_file(path)
	if not stream:
		get_tree().reload_current_scene()
		return
	$MusicPlayer.stream = stream
	$MusicPlayer.play()
	$MusicPlayer.stream_paused = true
	%Notes.size.x = stream.get_length() * 200
	
	var parts = path.rsplit("/", false, 1)
	if parts.size() > 1:
		level_name = parts[1]


func _on_play_button_pressed() -> void:
	#print($MusicPlayer.playing, $MusicPlayer.stream_paused)
	#if not $MusicPlayer.playing:
		#$MusicPlayer.play()
	#else:
		$MusicPlayer.stream_paused = not $MusicPlayer.stream_paused


func _on_back_button_pressed() -> void:
	$MusicPlayer.seek(max(0.0, play_pos - 5))


func _on_forward_button_pressed() -> void:
	$MusicPlayer.seek(min($MusicPlayer.stream.get_length(), play_pos + 5))


func _on_music_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_music_player_finished() -> void:
	$MusicPlayer.play()
	$MusicPlayer.stream_paused = true
