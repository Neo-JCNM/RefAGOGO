extends Node


@onready var textBoxScene = preload("res://Assets/Scenes/textBox.tscn")
@onready var anim = get_node_or_null("Sprite")

var dialogLines : Array = []
var currentLineIndex = 0
var _dialogStepId : int = 0

var textBox
var textBoxPosition : Vector2

var isDialogActive = false
var canAdvanceLine = false

func startDialog(position : Vector2, lines: Array):
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
	var stepId = _dialogStepId
	await get_tree().create_timer(0.5).timeout
	if isDialogActive and canAdvanceLine and _dialogStepId == stepId:
		_advanceLine()
	else:
		anim.play("Waiting")


func _unhandled_input(event):
	if isDialogActive and canAdvanceLine:
		if (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("ui_accept"):
			_advanceLine()


func _advanceLine():
	var a = ["Talking_1", "Talking_2", "Talking_3"]
	a.shuffle()		
	canAdvanceLine = false
	_dialogStepId += 1
	if is_instance_valid(textBox):
		textBox.queue_free()
	if anim:
		anim.play(a[0])
		
	currentLineIndex += 1
	if currentLineIndex >= dialogLines.size():
		isDialogActive = false
		currentLineIndex = 0
		anim.stop()
		return
		
	_showTextBox()

func stopDialog() -> void:
	if is_instance_valid(textBox):
		textBox.queue_free()
	textBox = null
	isDialogActive = false
	canAdvanceLine = false
	currentLineIndex = 0
	anim.stop()


func _on_main_menu_tree_exiting() -> void:
	stopDialog()
