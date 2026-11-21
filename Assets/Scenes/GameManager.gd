extends Control

var gamestate = "PALIER"
@export var tagList = ["Français", "Culte", "Horreur", "Action", "Américain", "Fantasy", "Drame"]
var registeredChoices = []
var choices = []
signal changementDePhase
signal endChoice

@export_group("Boutons")
@export var choiceButton1 : Button = null
@export var choiceButton2 : Button = null
@export var choiceButton3 : Button = null

@export_category("Sound Design")

@export var sfx : AudioStreamPlayer = null
@export var bgm : AudioStreamPlayer = null
@export var ymg : AudioStreamPlayer = null

@export var nope : AudioStreamWAV = null
@export var yes : AudioStreamWAV = null
@export var change : AudioStreamWAV = null

@export var intro : AudioStreamMP3 = null
@export var loop : AudioStreamMP3 = null

@export_category("Scenes")
@export var groupHolder : Control = null
@export var imageHolder : TextureRect = null
@export var videoHolder : VideoStreamPlayer = null
@export var textHolder : Button = null
@export var audioHolder : AudioStreamPlayer = null



var refPool = []
var historiqueRef = []
var Question : RefSO 

func _ready() -> void:
	groupHolder.hide()
	imageHolder.hide()
	videoHolder.hide()
	textHolder.hide()
	
	
	gamestate = "PALIER"
	changementDePhase.emit()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func choiceTag() -> Array:
	var Choice1 = tagList.pick_random()
	while Choice1 in registeredChoices :
		Choice1 = tagList.pick_random()
	var Choice2 = tagList.pick_random()
	while Choice1 == Choice2 || Choice2 in registeredChoices :
		Choice2 = tagList.pick_random()
	var Choice3 = tagList.pick_random()
	while (Choice1 == Choice3) || (Choice2 == Choice3) || Choice3 in registeredChoices:
		Choice3 = tagList.pick_random()
		
	return [Choice1, Choice2, Choice3]
	
	


func _on_changement_de_phase() -> void:
	match gamestate:
		"PALIER":
			choiceButton1.show()
			choiceButton2.show()
			choiceButton3.show()
			
			choices = choiceTag()
			choiceButton1.text = choices[0]
			choiceButton2.text = choices[1]
			choiceButton3.text = choices[2]
			
		"PREPQUESTION":
			get_refs()
		"QUIZ":
			chooseQuestion()
			mettreEnScene()
			pass

#region UI Boutton de choix
func _on_button_3_pressed() -> void:
	sfx.set_stream(yes)
	sfx.play()
	registeredChoices.append(choices[2])
	endChoice.emit()
	


func _on_button_2_focus_entered() -> void:
	sfx.set_stream(change)
	sfx.play()


func _on_button_2_pressed() -> void:
	sfx.set_stream(yes)
	sfx.play()
	registeredChoices.append(choices[1])
	endChoice.emit()
	
	


func _on_button_1_focus_entered() -> void:
	sfx.set_stream(change)
	sfx.play()


func _on_button_1_pressed() -> void:
	sfx.set_stream(yes)
	sfx.play()
	registeredChoices.append(choices[0])
	endChoice.emit()
	
	


func _on_button_3_focus_entered() -> void:
	sfx.set_stream(change)
	sfx.play()
#endregion

func _on_end_choice() -> void:
	choiceButton1.hide()
	choiceButton2.hide()
	choiceButton3.hide()
	gamestate = "PREPQUESTION"
	changementDePhase.emit()

func get_refs() -> void:
	for fichier in DirAccess.open("res://Assets/Data/Refs/Finaux/").get_files():
		var ref : RefSO = load("res://Assets/Data/Refs/Finaux/"+fichier)
		if(ref not in historiqueRef && ((ref.tag1 == registeredChoices[-1]) || (ref.tag2 == registeredChoices[-1]))):
			registeredChoices.append(ref)
			refPool.append(ref)
	gamestate = "QUIZ"
	changementDePhase.emit()
			
func chooseQuestion()->void:
	refPool.shuffle()
	Question = refPool.pop_front()
	
func mettreEnScene()->void:
	groupHolder.show()
	if Question.isAudio : audioHolder.show()
	elif Question.isTexte : 
		textHolder.show()
		textHolder.text = Question.texte
	elif Question.isVideo : 
		videoHolder.show()
		videoHolder.stream = Question.video
	elif Question.isImage : 
		imageHolder.show()
		imageHolder.texture = Question.image
	
	
