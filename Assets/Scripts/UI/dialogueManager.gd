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
	get_tree().root.add_child.call_deferred(textBox)
	textBox.global_position = textBoxPosition
	textBox.displayText(dialogLines[currentLineIndex])
	canAdvanceLine = false


func _onTextBodyFinishedDisplaying():
	canAdvanceLine = true
	

func _unhandled_input(event):
	if isDialogActive and canAdvanceLine:
		await get_tree().create_timer(1).timeout
		textBox.queue_free()
		if anim:
			anim.play("Talking_1")
			
		currentLineIndex += 1
		if currentLineIndex >= dialogLines.size():
			isDialogActive = false
			currentLineIndex = 0
			return
				
		_showTextBox()

func stopDialog() -> void:
	if is_instance_valid(textBox):
		textBox.queue_free()
	textBox = null
	isDialogActive = false
	canAdvanceLine = false
	currentLineIndex = 0


func _on_main_menu_tree_exiting() -> void:
	stopDialog()
