extends Node

var cheminRefs = "res://Assets/Data/Refs"

var buttons : Array[Button]
var questions : Array[Resource]
var themes : Array[String] = ["Français", "Culte"]
var index : int
var correct : int
var difficulty : float = 0.0

@onready var text : Label = $Question/Text
@onready var img : TextureRect = $Question/Ref/Img
@onready var video : VideoStreamPlayer = $Question/Ref/Video
@onready var audio : AudioStreamPlayer = $Question/Ref/Audio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in $Options.get_children():
		buttons.append(button)
	
	for question in DirAccess.open(cheminRefs).get_files():
		
		for theme in themes:
			if theme in load(cheminRefs.path_join(question)).tags:
				print(question, ":", theme)
				questions.append(question)
				break
	
	questions.shuffle()
	


func loadQuiz() -> void:
	for question in questions:
		if question.diff == min(int(difficulty), 5):
			if question is RefsTxt:
				print("text")
				text = question.src
			elif question is RefsAudio:
				print("audio")
				audio = question.src
			elif question is RefsImg:
				print("img")
				img = question.src
			elif question is RefsVideo:
				print("video")
				video = question.src
			else:
				print("error, exterminate!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
