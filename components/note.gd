extends Node2D

var deadline: float  # milisecond
var angle: float
var speed: float  # pixels per milisecond

func get_location() -> Vector2:  # pixels
	return Vector2.from_angle(-angle) * speed * (deadline - get_parent().song_pos * 1000)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	self.rotation = PI - angle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = get_location()
