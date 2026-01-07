extends TextureButton

signal deleted


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_on_left_click()
			MOUSE_BUTTON_RIGHT:
				_on_right_click()


func _on_left_click() -> void:
	print("clicked")


func _on_right_click() -> void:
	deleted.emit()
	queue_free()
