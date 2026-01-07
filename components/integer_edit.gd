extends LineEdit

var old_text = ""

signal value_changed(value: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = text if text else '0'
	old_text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed(new_text: String) -> void:
	print(new_text)
	if new_text.is_valid_int():
		old_text = text
		value_changed.emit(new_text.to_int())
	else:
		text = old_text
