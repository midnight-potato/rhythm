extends AudioStreamPlayer

const Note = preload("res://components/note.tscn")

@export var bpm: float = 120
@export var notes: Array = []
var spb: float # seconds per beat
var song_pos := 0.0
var next_beat_pos := 0.0
var last_beat: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spb = 60/bpm
	
	for item in notes:
		var note = Note.instantiate()
		note.deadline = item["t"] / bpm * 60000
		note.speed = item["s"]
		note.angle = PI * item["a"]
		add_child(note)
	
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		song_pos = get_playback_position() 
		if song_pos >= next_beat_pos:
			last_beat += 1
			next_beat_pos += spb
