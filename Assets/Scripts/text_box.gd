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
	
	# Rend la bulle invisible à l'œil pendant le calcul de taille (évite le sursaut)
	modulate.a = 0.0
	
	var bg = get_node_or_null("NinePatchRect")
	var margin = get_node("MarginContainer")
	label = get_node("MarginContainer/Label")
	timer = get_node("LetterDisplayTimer")
	
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2.ZERO
	
	if bg:
		bg.z_index = 0
	
	margin.visible = true
	margin.modulate = Color.WHITE
	margin.self_modulate = Color.WHITE
	margin.show_behind_parent = false
	margin.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.z_index = 10
	
	label.visible = true
	label.modulate = Color.WHITE
	label.self_modulate = Color.WHITE
	label.show_behind_parent = false
	label.material = null
	label.visible_characters = -1
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.z_index = 10
	
	if label.label_settings:
		label.label_settings.font_color = Color.BLACK
	else:
		label.add_theme_color_override("font_color", Color.BLACK)
		label.add_theme_font_size_override("font_size", 20)
	
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	text = textToDisplay
	letterIndex = 0
	label.text = textToDisplay
	
	if text.is_empty():
		modulate.a = 1.0
		finishedDisplaying.emit()
		return
	
	await get_tree().process_frame
	
	var measured_width = max(label.get_minimum_size().x + 32, size.x)
	custom_minimum_size.x = min(measured_width, MAX_WIDTH)
	size.x = custom_minimum_size.x
	
	if measured_width > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		await get_tree().process_frame
		custom_minimum_size.y = size.y
	
	# Place la bulle centrée au-dessus du point cible
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	# Vide le texte, réaffiche la bulle à sa position finale et lance l'animation
	label.text = ""
	modulate.a = 1.0
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
			

func _on_letter_display_timer_timeout() -> void:
	_displayLetter()
