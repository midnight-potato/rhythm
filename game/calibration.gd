extends Node2D

const Conductor = preload("res://components/conductor.tscn")
const Tier = preload('res://components/tier.tscn')
var conductor
var calibration: bool = false
var paused: bool = false
var stats: Dictionary = {
	'misses' = 0,
	'total_offset' = 0.0,
	'avg_offset' = 0.0,
	'calibration' = true
}
#const LEVEL = '{"bpm":60,"notes":[{"t":1,"s":1,"a":0.25},{"t":2,"s":1,"a":0.5}]}'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	paused = false
	$pauseMenu.visible = false
	# reading the level data
	var reader = ZIPReader.new()
	reader.open(GameState.selected_level)
	var data = JSON.parse_string(reader.read_file("level.json").get_string_from_utf8())
	var bpm = data["bpm"]
	var start = Time.get_ticks_msec()
	
	# music...
	var music_name = data["music"]
	var music = reader.read_file(music_name)
	var stream = AudioStreamMP3.new()
	stream.data = music
	
	var sync_stream = AudioStreamSynchronized.new()
	sync_stream.stream_count = 1
	sync_stream.set_sync_stream(0, stream)
	
	conductor = Conductor.instantiate()
	conductor.stream = sync_stream
	conductor.bpm = data["bpm"]
	conductor.notes = data["notes"]
	add_child(conductor)
	
	stats['total_notes'] = conductor.noteNodes.size()
	
	_update_stats_labels(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()
	if paused: return
	if Input.is_action_just_pressed("hit"):
		var hit_diff = conductor.get_hit_diff(false)
		if abs(hit_diff) < 0.15:
			stats['total_offset'] += hit_diff
			_update_stats_labels(hit_diff)
			conductor.remove_note()
	elif conductor.noteNodes.size() > 0 and conductor.noteNodes[0].deadline < conductor.song_pos - 0.15:
		stats["misses"] += 1
		conductor.remove_note()
	if not conductor.playing:
		stats['finished'] = false
		_update_stats()
		end_game()

func _update_stats_labels(diff: float) -> void:
	#$score.text = str(stats['score'])
	var s = "+" if diff > 0.0 else ""
	%offsetNum.text = s + str(snapped(diff * 1000, 0.001))

func _update_stats() -> void:
	stats['avg_offset'] = stats['total_offset'] / (stats['total_notes'] - stats['misses'])

func pause() -> void:
	paused = false if paused else true
	conductor.stream_paused = paused
	$pauseMenu.visible = paused

func restart_game() -> void:
	conductor.playing = false
	conductor.remove_all_notes()
	_ready()

func end_game() -> void:
	conductor.playing = false
	GameState.stats = stats
	print(stats)
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")
