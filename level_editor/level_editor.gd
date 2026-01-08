extends Control

const EditorNote = preload("res://level_editor/editor_note.tscn")

const ZOOM = 400

var bpm: int = 60
var notes: Array = []
var play_pos := 0.0
var music_path: String
var level_name := "unknown"

var is_setting_bpm := false
var first_bpm_tap := -1.0
var bpm_tap_count := 0

var snap := 4

var js_callback = JavaScriptBridge.create_callback(_on_javascript_file_change)
var js_load_callback = JavaScriptBridge.create_callback(_on_javascript_load)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web"):
		$WebLayer.visible = true
		_open_browser_select()
	else:
		$MusicDialog.show()


func _open_browser_select():
	var document = JavaScriptBridge.get_interface("document")
	var input = document.createElement('input')
	input.type = "file"
	input.accept = "audio/mp3,audio/mpeg,application/zip"
	input.onchange = js_callback
	input.click()


func _on_javascript_file_change(arguments: Array):
	var event = arguments[0]
	var file = event.target.files[0]
	
	var reader = JavaScriptBridge.create_object("FileReader")
	reader.onload = js_load_callback
	reader.readAsArrayBuffer(file)


func _on_javascript_load(arguments: Array):
	var data = JavaScriptBridge.js_buffer_to_packed_byte_array(arguments[0].target.result)

	var file = FileAccess.open("user://music.mp3", FileAccess.WRITE)
	file.store_buffer(data)
	file.close()

	_on_music_dialog_file_selected("user://music.mp3")
	$WebLayer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	play_pos = $MusicPlayer.get_playback_position()
	%Notes.position.x = get_viewport().get_visible_rect().size.x / 2 - play_pos * ZOOM
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
			var beat: float = round(play_pos / 60 * bpm * snap) / snap
			print('add note at ', play_pos, ', beat ', beat)
			_add_note(beat)


func _add_note(beat: float):
	for note in notes:
		if note["t"] == beat:
			return

	var note = { "t": beat, "a": fmod(beat,snap)/snap*2, "s": 1000 }
	notes.append(note)
	notes.sort_custom(func (a, b): return a["t"] < b["t"])

	_add_note_node(note)


func _add_note_node(note: Dictionary):
	var beat = note["t"]
	var node: Control = EditorNote.instantiate()
	node.position.x = beat / bpm * 60 * ZOOM
	node.connect("deleted", func (): return _on_note_deleted(beat))
	%Notes.add_child(node)


func _on_note_deleted(beat: float):
	print('before: ', notes.size())
	notes = notes.filter(func (note): return note["t"] != beat)
	print('after:  ', notes.size())


# call this instead of updating the value of bpm!
func set_bpm(value: int):
	print("bpm set to ", value)
	bpm = value
	%BPMValue.text = str(bpm)
	%BPMValue.set_caret_column(str(bpm).length())


func _on_music_dialog_canceled() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_music_dialog_file_selected(path: String):
	# check if it's a game zip file
	var reader = ZIPReader.new()
	var error = reader.open(path)
	if error == OK:
		_on_zip_file_opened(reader)
		return
	
	_load_stream(path)
	
	var parts = path.rsplit("/", false, 1)
	if parts.size() > 1:
		level_name = parts[1]


func _load_stream(path: String):
	music_path = path
	var stream = AudioStreamMP3.load_from_file(path)
	if not stream:
		get_tree().reload_current_scene()
		return
	var sync_stream = AudioStreamSynchronized.new()
	sync_stream.stream_count = 1
	sync_stream.set_sync_stream(0, stream)
	$MusicPlayer.stream = sync_stream
	$MusicPlayer.play()
	$MusicPlayer.stream_paused = true
	%Notes.size.x = stream.get_length() * ZOOM


func _on_zip_file_opened(reader: ZIPReader):
	var level_data = JSON.parse_string(reader.read_file("level.json").get_string_from_utf8())
	var music_data = reader.read_file(level_data["music"])
	
	var file = FileAccess.open("user://playing.mp3", FileAccess.WRITE)
	file.store_buffer(music_data)
	
	level_name = level_data["music"]
	set_bpm(int(level_data["bpm"]))
	_load_stream("user://playing.mp3")
	notes = level_data["notes"]
	
	for note in notes:
		_add_note_node(note)


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


func _on_export_button_pressed():
	var writer = ZIPPacker.new()
	var err = writer.open("user://level.zip")
	if err != OK:
		return
	
	var level_data = JSON.stringify({"bpm": bpm, "notes": notes, "music": "music.mp3"})
	writer.start_file("level.json")
	writer.write_file(level_data.to_utf8_buffer())
	writer.close_file()
	
	writer.start_file("music.mp3")
	writer.write_file(FileAccess.get_file_as_bytes(music_path))
	writer.close_file()

	writer.close()
	
	var level_bytes = FileAccess.get_file_as_bytes("user://level.zip")
	
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(level_bytes, level_name + ".zip", "application/zip")


func _on_web_open_button_pressed() -> void:
	_open_browser_select()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
