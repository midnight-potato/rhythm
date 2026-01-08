extends Node

var _js_file_change = JavaScriptBridge.create_callback(_on_js_file_change)
var _js_load = JavaScriptBridge.create_callback(_on_js_load)

var _file_name = "unknown"

signal file_selected(path: String)
signal canceled


func select():
	_file_name = "unknown"
	if OS.has_feature("web"):
		%WebPanel.visible = true
		_open_browser_select()
	else:
		$FileDialog.visible = true

# web javascript goofery

func _open_browser_select():
	var document = JavaScriptBridge.get_interface("document")
	var input = document.createElement('input')
	input.type = "file"
	input.accept = "audio/vnd.wav,audio/vnd.wave,audio/wave,application/zip"
	input.onchange = _js_file_change
	input.click()


func _on_js_file_change(arguments: Array):
	var event = arguments[0]
	var file = event.target.files[0]
	_file_name = file.name
	
	var reader = JavaScriptBridge.create_object("FileReader")
	reader.onload = _js_load
	reader.readAsArrayBuffer(file)


func _on_js_load(arguments: Array):
	var data = JavaScriptBridge.js_buffer_to_packed_byte_array(arguments[0].target.result)
	var path = "user://" + _file_name

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()

	file_selected.emit(path)
	%WebPanel.visible = false


func _on_open_button_pressed() -> void:
	select()


func _on_cancel_button_pressed() -> void:
	canceled.emit()
	%WebPanel.visible = false

# filedialogs are much easier

func _on_file_dialog_file_selected(path: String) -> void:
	file_selected.emit(path)
	$FileDialog.hide()


func _on_file_dialog_canceled() -> void:
	canceled.emit()
