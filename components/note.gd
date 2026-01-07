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
	self.position = Vector2.from_angle(-angle) * (speed * (deadline - get_parent().get_offset_pos()) + radius)

func hit() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($knife, 'modulate:a', 0.0, 0.05)
	tween.set_parallel(false)
	tween.tween_callback(self.queue_free)

func get_hitmarker_pos() -> Vector2:
	return $hitmarkerLocation.global_position
