extends Node


@onready var textBoxScene = preload("res://Assets/Scenes/textBox.tscn")
@onready var anim = get_node_or_null("Sprite")

var dialogLines : Array[String] = []
var currentLineIndex = 0

var textBox
var textBoxPosition : Vector2

var isDialogActive = false
var canAdvanceLine = false

func startDialog(position : Vector2, lines: Array[String]):
	if isDialogActive:
		return
	
	if anim:
		anim.play("Talking_2")
	dialogLines = lines
	textBoxPosition = position
	_showTextBox()
	
	isDialogActive = true


func _showTextBox():
	textBox = textBoxScene.instantiate()
	textBox.finishedDisplaying.connect(_onTextBodyFinishedDisplaying)
	get_tree().root.add_child(textBox)
	textBox.global_position = textBoxPosition
	textBox.displayText(dialogLines[currentLineIndex])
	canAdvanceLine = false


func _onTextBodyFinishedDisplaying():
	canAdvanceLine = true
	

func _unhandled_input(event):
	if (
		event is InputEventMouse &&
		event.pressed() &&
		isDialogActive &&
		canAdvanceLine
	):
		textBox.queue_free()
		anim.play("Talking_1")
		
		currentLineIndex += 1
		if currentLineIndex >= dialogLines.size():
			isDialogActive = false
			currentLineIndex = 0
			return
			
		_showTextBox()
