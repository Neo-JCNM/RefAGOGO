extends MarginContainer

const MAX_WIDTH = 256

var label : Label
var timer : Timer

var text = ""
var letterIndex = 0

var letterTime = 0.03
var spaceTime = 0.06
var punctuationTime = 0.2

signal finishedDisplaying()


func displayText(textToDisplay: String):
	if not is_node_ready():
		await ready
	
	# Récupération directe des nœuds une fois la scène 100 % prête
	label = get_node("MarginContainer/Label")
	timer = get_node("LetterDisplayTimer")
	
	text = textToDisplay
	letterIndex = 0
	label.text = textToDisplay
	
	if text.is_empty():
		finishedDisplaying.emit()
		return
	
	# Laisse une frame à Godot pour calculer la taille réelle du texte
	await get_tree().process_frame
	
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	label.text = ""
	_displayLetter()


func _displayLetter():
	label.text += text[letterIndex]
	
	letterIndex += 1
	if letterIndex >= text.length():
		finishedDisplaying.emit()
		return 
		
	match text[letterIndex]:
		"!", ".", ",", "?":
			timer.start(punctuationTime)
		" ":
			timer.start(spaceTime)
		_:
			timer.start(letterTime)
			
	print("ETAT LABEL -> text: '", label.text, "' | size: ", label.size, " | vis_chars: ", label.visible_characters, " | settings: ", label.label_settings)


func _on_letter_display_timer_timeout() -> void:
	_displayLetter()
