extends Node

var cheminRefs = "res://Assets/Data/Refs"

var buttons : Array[Button]
var questions : Array[Resource]
var themes : Array[String] = ["Français", "Culte"]
var index : int = 0
var correct : int = 0
var difficulty : float = 0.0

@onready var text : Label = $Question/Text
@onready var img : TextureRect = $Question/Ref/Img
@onready var video : VideoStreamPlayer = $Question/Ref/Video
@onready var audio : AudioStreamPlayer = $Question/Ref/Audio

func _ready() -> void:
	for button in $Options.get_children():
		buttons.append(button)
	
	var dir = DirAccess.open(cheminRefs)
	if dir:
		for nom_fichier in dir.get_files():
			var nom_propre = nom_fichier.trim_suffix(".remap")
			if not nom_propre.ends_with(".tres"):
				continue
				
			var res = load(cheminRefs.path_join(nom_propre))
			if res:
				for theme in themes:
					if theme in res.tags:
						print(nom_propre, " : ", theme)
						questions.append(res)
						break
	
	questions.shuffle()
	
	loadQuiz()

func loadQuiz() -> void:
	while index < questions.size():
		var question = questions[index]
		
		if question.diff == min(int(difficulty), 5):
			text.text = ""
			img.texture = null
			audio.stop()
			video.stop()
			
			if question is RefsTxt:
				print("text")
				text.text = question.src
			elif question is RefsAudio:
				print("audio")
				audio.stream = question.src
				audio.play()
			elif question is RefsImg:
				print("img")
				img.texture = question.src
			elif question is RefsVideo:
				print("video")
				video.stream = question.src
				video.play()
			else:
				print("error, exterminate!")
			
			index += 1
			return 
		
		index += 1
		
	print("Fin du quiz, plus de questions disponibles !")
