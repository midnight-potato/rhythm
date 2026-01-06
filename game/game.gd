extends Node2D

const Conductor = preload("res://components/conductor.tscn")
const Tier = preload('res://components/tier.tscn')
var conductor
var combo: int = 0
#const LEVEL = '{"bpm":60,"notes":[{"t":1,"s":1,"a":0.25},{"t":2,"s":1,"a":0.5}]}'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	update_stats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hit"):
		if conductor.if_hit():
			var tier := calc_score(conductor.get_hit_diff())
			GameState.score += tier['score']
			print(tier['tier'], "!")
			conductor.remove_note()
			combo += 1
			_spawn_tier(tier['tier'])
			update_stats()
			print("current score: ", GameState.score)
			print("current combo: ", combo)
		else:
			combo = 0
	elif conductor.noteNodes.size() > 0 and conductor.noteNodes[0].deadline < conductor.song_pos - 0.095:
		conductor.remove_note()
		combo = 0
		update_stats()
	# TODO pausing and finish level

func _spawn_tier(text: String) -> void:
	var tier = Tier.instantiate()
	tier.fade_time = 0.41
	tier.travel_speed = 160.0
	tier.set_text(text)
	$tierSpawn.add_child(tier)

func calc_score(diff: float) -> Dictionary:
	for tier in GameState.tiers:
		if diff < tier['threshold']:
			return tier
	return {'tier': 'Miss', 'score': 0.0}

func update_stats():
	#$score.text = str(GameState.score)
	%comboNum.text = str(combo)
