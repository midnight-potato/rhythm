extends Node2D

const Conductor = preload("res://components/conductor.tscn")
var conductor
const max_score := 10.0
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hit"):
		if conductor.if_hit():
			var tier := calc_score(conductor.get_hit_diff())
			GameState.score += tier['score']
			print(tier['tier'], "!")
			conductor.remove_note()
			update_score()
			print("current score: ", GameState.score)

func calc_score(diff: float) -> Dictionary:
	for tier in GameState.tiers:
		if diff < tier['threshold']:
			return tier
	return {'tier': 'Miss', 'score': 0.0}


func update_score():
	$score.text = str(GameState.score)
