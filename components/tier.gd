extends Node2D

var elapsed_time := 0.0
var travel_dist := 10.0
var fade_time := 0.45

func _ready() -> void:
	#elapsed_time += delta
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, 'position:y', position.y - travel_dist, fade_time)
	tween.tween_property(self, 'modulate:a', 0.0, fade_time)
	tween.set_parallel(false)
	tween.tween_callback(self.queue_free)

func set_text(t: String, o: float) -> void:
	$tierLabel.text = t
	var s = "+" if o > 0.0 else ""
	var off = "" if o == -1.0 else s + str(snapped(o, 0.001))
	$timeOffset.text = off
