extends Node2D

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rotation = rng.randf_range(0.0, TAU)
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'rotation', rotation + rng.randf_range(-PI/2, PI/2) * 0.1, 0.15)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, 'modulate:a', 0.0, 0.15)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($hitmarkerSprite, 'scale', Vector2(0.15, 0.15), 0.15)
	tween.set_parallel(false)
	tween.tween_callback(self.queue_free)
