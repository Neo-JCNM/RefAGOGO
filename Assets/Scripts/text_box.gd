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
	text = textToDisplay
	label.text = textToDisplay
	
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
		
