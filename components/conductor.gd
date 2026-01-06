extends AudioStreamPlayer

@export var bpm: float = 120
@export var offset: float = 0.0
var spb: float # seconds per beat
var song_pos := 0.0
var next_beat_pos := 0.0
var last_beat: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spb = 60/bpm

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		song_pos = get_playback_position() 
		if song_pos >= next_beat_pos:
			last_beat += 1
			next_beat_pos += spb
