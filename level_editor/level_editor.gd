extends Control

const EditorNote = preload("res://level_editor/editor_note.tscn")

var bpm: int = 60
var notes: Array[Dictionary] = []
var play_pos := 0.0
var level_name := "unknown"

var is_setting_bpm := false
var first_bpm_tap := -1.0
var bpm_tap_count := 0

var snap := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicDialog.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	play_pos = $MusicPlayer.get_playback_position() + AudioServer.get_time_since_last_mix()
	%Notes.position.x = get_viewport().get_visible_rect().size.x / 2 - play_pos * 200
	%PlayButton.text = "▶️" if not $MusicPlayer.playing or $MusicPlayer.stream_paused else "⏸️"
	%TitleLabel.text = "Editing level: " + level_name
	%BPMButton.text = "Stop BPM" if is_setting_bpm else "Tap BPM"

	if $MusicPlayer.stream_paused:
		is_setting_bpm = false

	if Input.is_action_just_pressed("hit"):
		if is_setting_bpm:
			if first_bpm_tap < 0:
				first_bpm_tap = play_pos
			else:
				bpm_tap_count += 1
				set_bpm(round(bpm_tap_count / (play_pos - first_bpm_tap) * 60.0))
		else:
			print('add note at ', play_pos)
			var beat: float = round(play_pos / 60 * bpm * snap) / snap
			_add_note(beat)


func _add_note(beat: float):
	var note = { "t": beat, "a": fmod(beat,snap)/snap*2, "s": 1000 }
	notes.append(note)
	
	var node: Sprite2D = EditorNote.instantiate()
	node.position.x = beat * bpm / 60 * 200
	%Notes.add_child(node)


# call this instead of updating the value of bpm!
func set_bpm(value: int):
	print("bpm set to ", value)
	bpm = value
	%BPMValue.text = str(bpm)
	%BPMValue.set_caret_column(str(bpm).length())


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


func _on_music_player_finished() -> void:
	$MusicPlayer.play()
	$MusicPlayer.stream_paused = true


func _on_play_button_pressed() -> void:
	$MusicPlayer.stream_paused = not $MusicPlayer.stream_paused


func _on_back_button_pressed() -> void:
	$MusicPlayer.seek(max(0.0, play_pos - 5))


func _on_forward_button_pressed() -> void:
	$MusicPlayer.seek(min($MusicPlayer.stream.get_length(), play_pos + 5))


func _on_music_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_bpm_button_pressed() -> void:
	is_setting_bpm = not is_setting_bpm
	if is_setting_bpm:
		bpm_tap_count = 0
		first_bpm_tap = -1.0


func _on_bpm_value_changed(value: int) -> void:
	set_bpm(value)


func _on_snap_value_changed(value: int) -> void:
	snap = value
