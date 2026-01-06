extends Node2D


const Note = preload("res://components/note.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var note = Note.instantiate()
	note.deadline = Time.get_ticks_msec() + 2000
	note.speed = 1
	note.angle = PI / 4
	add_child(note)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
