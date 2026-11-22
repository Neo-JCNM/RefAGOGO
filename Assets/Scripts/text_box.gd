extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $letterDisplayTimer

const MAX_WIDTH = 256

var text = ""
var letterIndex = 0

var letterTime = 0.03
var spaceTime = 0.06
var punctuationTime = 0.2


signal finishedDisplaying()


func displayText(textToDisplay: String):
	if not is_node_ready():
		await ready
	if label == null:
		push_error("Label introuvable : vérifie le chemin $MarginContainer/Label")
		return
	
	text = textToDisplay
	label.text = textToDisplay
	if text.is_empty():
		finishedDisplaying.emit()
		return
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if MAX_WIDTH < size.x:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # x resize
		await resized # y resize
		custom_minimum_size.y = size.y
		
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	label.text = ""
	_displayLetter()
	

func _displayLetter():
	label.text += text[letterIndex]
	
	letterIndex += 1
	if text.length() <= letterIndex:
		finishedDisplaying.emit()
		return 
		
	match text[letterIndex]:
		"!",".",",","?":
			timer.start(punctuationTime)
		" ":
			timer.start(spaceTime)
		_:
			timer.start(letterTime)


func _on_letter_display_timer_timeout() -> void:
	_displayLetter()
