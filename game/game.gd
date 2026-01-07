extends Node2D

const Conductor = preload("res://components/conductor.tscn")
const Tier = preload('res://components/tier.tscn')
const Hitmarker = preload("res://components/hitmarker.tscn")
var conductor
var paused: bool = false
var tier_counts: Dictionary
var stats: Dictionary = {
	'score' = 0,
	'max_combo' = 0,
	'perfects' = 0,
	'combo' = 0,
	'misses' = 0,
	'total_offset' = 0.0,
	'avg_offset' = 0.0,
	'finished' = false,
	'percentage_notes' = 0.0,
	'percentage_score' = 0.0,
	'percentage_overall' = 0.0
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
	
	var sync_stream = AudioStreamSynchronized.new()
	sync_stream.stream_count = 1
	sync_stream.set_sync_stream(0, stream)
	
	conductor = Conductor.instantiate()
	conductor.stream = sync_stream
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
	if conductor.is_finished:
		stats['finished'] = true
		_update_stats()
		end_game()
	if Input.is_action_just_pressed("hit"):
		if conductor.if_hit():
			var hit_diff = conductor.get_hit_diff(false)
			var tier := calc_score(abs(hit_diff))
			if tier['tier'] == 'Miss':
				_miss_note()
				return
			stats['total_offset'] += hit_diff
			stats['score'] += tier['score']
			print(tier['tier'], "!")
			stats['combo'] += 1
			tier_counts[tier['tier']] += 1
			_spawn_tier(tier['tier'], hit_diff, tier['color'])
			_spawn_hitmarker(tier['hitmarker'])
			conductor.remove_note()
			_update_stats_labels()
			print("current score: ", stats['score'])
			print("current combo: ", stats['combo'])
	elif conductor.noteNodes.size() > 0 and conductor.noteNodes[0].deadline < conductor.get_offset_pos() - 0.1:
		_miss_note()

func _spawn_hitmarker(imgpath: String):
	var hitm = Hitmarker.instantiate()
	hitm.set_hitmarker_img(imgpath)
	hitm.global_position = conductor.noteNodes[0].get_hitmarker_pos()
	add_child(hitm)

func _miss_note() -> void:
	tier_counts["Miss"] += 1
	_spawn_tier('Miss', -1.0, GameState.tiers[GameState.size()-1]['color'])
	conductor.remove_note()
	stats['max_combo'] = stats['combo'] if stats['combo'] > stats['max_combo'] else stats['max_combo']
	stats['combo'] = 0
	_update_stats_labels()

func _spawn_tier(text: String, offset: float, color: Color) -> void:
	var tier = Tier.instantiate()
	tier.fade_time = 0.25
	tier.travel_dist = 120.0
	tier.set_text(text, offset)
	tier.set_color(color)
	$tierSpawn.add_child(tier)

func calc_score(diff: float) -> Dictionary:
	for tier in GameState.tiers:
		if diff < tier['threshold']:
			return tier
	return {'tier': 'Miss', 'score': 0}

func _update_stats_labels() -> void:
	#$score.text = str(stats['score'])
	%comboNum.text = str(stats['combo'])

func _update_stats() -> void:
	stats['perfects'] = tier_counts['Perfect']
	stats['max_combo'] = stats['combo'] if stats['combo'] > stats['max_combo'] else stats['max_combo']
	stats['misses'] = tier_counts['Miss']
	#stats['total_notes'] -= conductor.noteNodes.size()
	stats['avg_offset'] = stats['total_offset'] / (stats['total_notes'] - stats['misses'])
	stats['percentage_notes'] = (stats['total_notes'] - stats['misses']) / float(stats['total_notes'])
	stats['percentage_score'] = stats['score'] / float(stats['total_notes'] * GameState.tiers[0]['score'])
	stats['percentage_overall'] = stats['percentage_notes'] * 0.75 + stats['percentage_score'] * 0.25

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
