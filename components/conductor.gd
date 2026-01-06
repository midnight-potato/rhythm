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
		add_child(note)
		noteNodes.append(note)
	
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		song_pos = get_playback_position() + AudioServer.get_time_since_last_mix()
	
	while not noteNodes.is_empty() and noteNodes[0].deadline < song_pos - 0.100:
		noteNodes[0].queue_free()
		noteNodes.pop_front()
	
	if Input.is_action_just_pressed("hit"):
		if not noteNodes.is_empty():
			var note = noteNodes[0]
			if abs(note.deadline - song_pos) < 0.040:
				note.queue_free()
				noteNodes.pop_front()
