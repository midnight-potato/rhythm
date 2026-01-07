extends Node2D

var deadline: float  # seconds
var angle: float
var speed: float  # pixels per second
var radius: float # offset from the center, in pixels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.rotation = PI - angle + PI/2
	self.position = Vector2(100000, 100000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print('! ', get_parent().song_pos)
	self.position = Vector2.from_angle(-angle) * (speed * (deadline - get_parent().song_pos) + radius)
