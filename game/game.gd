extends Node2D

const Conductor = preload("res://components/conductor.tscn")
const Tier = preload('res://components/tier.tscn')
var conductor
var paused: bool = false
var tier_counts: Dictionary
var stats: Dictionary = {
	'score' = 0.0,
	'max_combo' = 0,
	'perfects' = 0,
	'combo' = 0,
	'misses' = 0,
	'total_offset' = 0.0,
	'avg_offset' = 0.0,
	'finished' = false
}
#const LEVEL = '{"bpm":60,"notes":[{"t":1,"s":1,"a":0.25},{"t":2,"s":1,"a":0.5}]}'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tier_counts = {"Miss": 0}
	for tier in GameState.tiers:
		tier_counts[tier["tier"]] = 0
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
	
	conductor = Conductor.instantiate()
	conductor.stream = stream
	conductor.bpm = data["bpm"]
	conductor.notes = data["notes"]
	add_child(conductor)
	
	stats['total_notes'] = conductor.noteNodes.size()
	
	_update_stats_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()
	if paused: return
	if Input.is_action_just_pressed("hit"):
		if conductor.if_hit():
			var hit_diff = conductor.get_hit_diff(true)
			stats['total_offset'] += hit_diff
			var tier := calc_score(hit_diff)
			stats['score'] += tier['score']
			print(tier['tier'], "!")
			stats['combo'] += 1
			tier_counts[tier['tier']] += 1
			_spawn_tier(tier['tier'], hit_diff)
			conductor.remove_note()
			_update_stats_labels()
			print("current score: ", stats['score'])
			print("current combo: ", stats['combo'])
	elif conductor.noteNodes.size() > 0 and conductor.noteNodes[0].deadline < conductor.song_pos - 0.095:
		tier_counts["Miss"] += 1
		_spawn_tier('Miss', -1.0)
		conductor.remove_note()
		stats['max_combo'] = stats['combo'] if stats['combo'] > stats['max_combo'] else stats['max_combo']
		stats['combo'] = 0
		_update_stats_labels()
	if not conductor.playing:
		stats['finished'] = true
		_update_stats()
		end_game()
	# TODO pausing and finish level

func _spawn_tier(text: String, offset: float) -> void:
	var tier = Tier.instantiate()
	tier.fade_time = 0.41
	tier.travel_speed = 160.0
	tier.set_text(text, offset)
	$tierSpawn.add_child(tier)

func calc_score(diff: float) -> Dictionary:
	for tier in GameState.tiers:
		if diff < tier['threshold']:
			return tier
	return {'tier': 'Miss', 'score': 0.0}

func _update_stats_labels() -> void:
	#$score.text = str(stats['score'])
	%comboNum.text = str(stats['combo'])

func _update_stats() -> void:
	stats['perfects'] = tier_counts['Perfect']
	stats['max_combo'] = stats['combo'] if stats['combo'] > stats['max_combo'] else stats['max_combo']
	stats['misses'] = tier_counts['Miss']
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
	print(tier_counts)
	print(stats)
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")
