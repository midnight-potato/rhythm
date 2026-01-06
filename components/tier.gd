extends Node2D

@onready var fade_shader: ShaderMaterial = $tierLabel.material
var elapsed_time := 0.0
var travel_speed := 150.0
var fade_time := 0.45

func _process(delta: float) -> void:
	elapsed_time += delta
	if not fade_shader: 
		return
	fade_shader.set_shader_parameter("current_time", elapsed_time)
	fade_shader.set_shader_parameter("fadeout_time", fade_time)
	self.position.y -= travel_speed * delta
	if elapsed_time > fade_time:
		self.queue_free()

func set_text(t: String, o: float) -> void:
	$tierLabel.text = t
	var s = "+" if o > 0.0 else ""
	var off = "" if o == -1.0 else s + str(snapped(o, 0.001))
	$timeOffset.text = off
