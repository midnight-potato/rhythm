extends AudioStreamPlayer

const Note = preload("res://components/note.tscn")

@export var bpm: float = 120
@export var notes: Array = []
var song_pos := 0.0

var score := 0

var noteNodes: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in notes:
		var note = Note.instantiate()
		note.deadline = item["t"] / bpm * 60
		note.speed = item["s"]
		note.angle = PI * item["a"]
		note.radius = 100.0
		add_child(note)
		noteNodes.append(note)
	
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if playing:
		song_pos = get_playback_position() + AudioServer.get_time_since_last_mix()
	
	while not noteNodes.is_empty() and noteNodes[0].deadline < song_pos - 0.100:
		print("miss!")
		noteNodes[0].queue_free()
		noteNodes.pop_front()

func get_hit_diff():
	if noteNodes.is_empty(): return 0.0
	return abs(song_pos - noteNodes[0].deadline)

func if_hit() -> bool:
	if noteNodes.is_empty(): return false
	if get_hit_diff() < 0.100:
		return true
	return false

func remove_note() -> void:
	if not noteNodes.is_empty():
		var note = noteNodes[0]
		note.queue_free()
		noteNodes.pop_front()
