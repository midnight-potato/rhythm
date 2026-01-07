extends AudioStreamPlayer

const Note = preload("res://components/note.tscn")
const Hitmarker = preload("res://components/hitmarker.tscn")

@export var bpm: float = 120
@export var notes: Array = []
var song_pos := 0.0

var is_finished := false

var noteNodes: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remove_all_notes()
	for item in notes:
		var note = Note.instantiate()
		note.deadline = item["t"] / bpm * 60
		note.speed = item["s"]
		note.angle = PI * item["a"]
		note.radius = 100.0
		print("note added for ", note.deadline)
		add_child(note)
		noteNodes.append(note)
	
	#stop()
	#
	#await get_tree().create_timer(2).timeout
	
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(playing, " ", stream_paused)
	if playing and not stream_paused:
		song_pos = get_playback_position()
		print(get_playback_position())

func get_offset_pos() -> float:
	return song_pos + GameState.input_offset

func get_hit_diff(absolute: bool):
	if noteNodes.is_empty(): return 0.0
	var diff = get_offset_pos() - noteNodes[0].deadline
	if absolute: return abs(diff)
	return diff

func if_hit() -> bool:
	if noteNodes.is_empty(): return false
	if get_hit_diff(true) < GameState.tiers[GameState.tiers.size()-1]['threshold']:
		return true
	return false

func remove_note() -> void:
	if not noteNodes.is_empty():
		var note = noteNodes[0]
		note.hit()
		var hitm = Hitmarker.instantiate()
		hitm.global_position = note.get_hitmarker_pos()
		add_child(hitm)
		noteNodes.pop_front()

func remove_all_notes() -> void:
	if not noteNodes.is_empty():
		for note in noteNodes:
			note.queue_free()
		noteNodes.clear()

func _on_finished() -> void:
	is_finished = true
