extends Control

enum State { PALIER, PREP_QUESTION, QUIZ, CLEAR, VICTORY, GAME_OVER }

signal changementDePhase(nouvel_etat: State)
signal endChoice
signal gameOver
signal victory

const GAME_OVER_SCENE: PackedScene = preload("res://Assets/Scenes/GameOver.tscn")
const REFS_PATH: String = "res://Assets/Data/Refs/Finaux/"
const QUESTIONS_PAR_PALIER: int = 4
const MAX_PALIER: int = 5
const MIN_DIFF: int = 0
const MAX_DIFF: int = 5

const DIFF_WEIGHTS_BY_PALIER: Dictionary = {
	1: [35.0, 35.0, 20.0, 7.0, 2.0, 1.0],
	2: [20.0, 30.0, 25.0, 15.0, 7.0, 3.0],
	3: [10.0, 18.0, 27.0, 25.0, 13.0, 7.0],
	4: [5.0, 10.0, 20.0, 30.0, 22.0, 13.0],
	5: [2.0, 5.0, 13.0, 28.0, 30.0, 22.0]
}

@export var tagList: Array[String] = ["Français", "Comédie", "Horreur", "Action", "Américain", "Fantasy", "Drame", "Thriller", "Sci-Fi"]
@export var victoryScene: PackedScene = null

@export var shopBg: Texture2D = null
@export var bgContainer: Sprite2D = null

@export_group("Boutons")
@export var choiceButton1: Button = null
@export var choiceButton2: Button = null
@export var choiceButton3: Button = null

@export_category("Sound Design")
@export var sfx: AudioStreamPlayer = null
@export var bgm: AudioStreamPlayer = null
@export var ymg: AudioStreamPlayer = null

@export var nope: AudioStreamWAV = null
@export var yes: AudioStreamWAV = null
@export var change: AudioStreamWAV = null

@export var intro: AudioStreamMP3 = null
@export var loop: AudioStreamMP3 = null

@export_category("Scenes")
@export var groupHolder: Control = null
@export var imageHolder: TextureRect = null
@export var videoHolder: VideoStreamPlayer = null
@export var textHolder: Button = null
@export var audioHolder: AudioStreamPlayer = null
@export var textBar: LineEdit = null

@export_category("Shop")
@export var moneyDisplayer: RichTextLabel = null
@export var boutique: Control = null

@onready var presentateur = $YmgParlant
@onready var pos = $YmgParlant/BulleReponse

#region dialogues
var victoires : Array = [
	["Bien joué, même si un nouveau-né l'aurait eu aussi !"],
	["Bravo, tu es aussi fort que monsieur-tout-le-monde !"],
	["Pas mal, tu es plus cultivé que tu en as l'air !"],
	["Ok, tu te débrouilles mieux que ce que j'imaginais !"],
	["Chapeau, beaucoup se sont plantés ici !"],
	["Mes félicitations, tu as surpassé toutes mes attentes !"]
]

var defaites: Array = [
	["..."],
	["Allooooo ! Y a quelqu'un au bout du fil ?"],
	["Quoi ?? Tout le monde l'avait celle-la !"],
	["Fais un effort, c'était simple pourtant..."],
	["J'en attendais un peu mieux de toi"],
	["Logique, tu ne fais pas partie de l'élite..."]
]
#endregion

var gamestate: State = State.PALIER
var activeTags: Array[String] = []
var choices: Array[String] = []

var Vie: int = 3
var Etape: int = 0
var Palier: int = 1
var Money: int = 0
var performanceScore: float = 0.0

var refPool: Array[RefSO] = []
var historiqueRef: Array[RefSO] = []
var Question: RefSO = null


func _ready() -> void:
	fermerScene()
	boutique.hide()
	
	var choice_buttons: Array[Button] = [choiceButton1, choiceButton2, choiceButton3]
	for i in range(choice_buttons.size()):
		choice_buttons[i].pressed.connect(_on_choice_button_pressed.bind(i))
		choice_buttons[i].focus_entered.connect(_on_choice_button_focus_entered)
	
	textBar.text_submitted.connect(_on_text_submitted)
	
	moneyDisplayer.show()
	_update_money_ui()
	_change_state(State.PALIER)


func _unhandled_input(event: InputEvent) -> void:
	if gamestate == State.QUIZ and Question != null and event.is_action_pressed("Verif"):
		_verifier_reponse(textBar.text)
		get_viewport().set_input_as_handled()


func _change_state(new_state: State) -> void:
	gamestate = new_state
	changementDePhase.emit(gamestate)
	
	match gamestate:
		State.PALIER:
			_update_money_ui()
			fermerScene()
			boutique.hide()
			_set_choice_buttons_visible(true)
			
			choices = choiceTag()
			choiceButton1.text = choices[0]
			choiceButton2.text = choices[1]
			choiceButton3.text = choices[2]
			choiceButton1.grab_focus()
			
		State.PREP_QUESTION:
			_set_choice_buttons_visible(false)
			get_refs()
			
		State.QUIZ:
			_update_money_ui()
			if chooseQuestion():
				mettreEnScene()
			else:
				_change_state(State.PALIER)
				
		State.CLEAR:
			fermerScene()
			Money += 10
			_update_money_ui()
			boutique.show()
			
		State.VICTORY:
			_update_money_ui()
			fermerScene()
			boutique.hide()
			victory.emit()
			if victoryScene != null:
				get_tree().change_scene_to_packed(victoryScene)
			
		State.GAME_OVER:
			fermerScene()
			gameOver.emit()
			get_tree().change_scene_to_packed(GAME_OVER_SCENE)


func continuer_apres_boutique() -> void:
	if gamestate == State.CLEAR:
		Palier += 1
		_change_state(State.PALIER)


func choiceTag() -> Array[String]:
	var disponibles: Array[String] = []
	for tag in tagList:
		if tag not in activeTags:
			disponibles.append(tag)
	
	if disponibles.size() < 3:
		disponibles = tagList.duplicate()
	
	disponibles.shuffle()
	return [disponibles[0], disponibles[1], disponibles[2]]


func _on_choice_button_pressed(index: int) -> void:
	_play_sfx(yes)
	var chosen_tag := choices[index]
	if chosen_tag not in activeTags:
		activeTags.append(chosen_tag)
	endChoice.emit()
	_change_state(State.PREP_QUESTION)


func _on_choice_button_focus_entered() -> void:
	_play_sfx(change)


func get_refs() -> void:
	refPool.clear()
	var dir := DirAccess.open(REFS_PATH)
	if dir == null:
		push_error("Impossible d'ouvrir le dossier : " + REFS_PATH)
		return
	
	for fichier in dir.get_files():
		var clean_name := fichier.trim_suffix(".remap")
		if not (clean_name.ends_with(".tres") or clean_name.ends_with(".res")):
			continue
		
		var ref := load(REFS_PATH + clean_name) as RefSO
		if ref != null and ref not in historiqueRef and (ref.tag1 in activeTags or ref.tag2 in activeTags):
			refPool.append(ref)
	
	_change_state(State.QUIZ)


func _get_question_weight(ref: RefSO) -> float:
	var palier_clamped := clampi(Palier, 1, MAX_PALIER)
	var diff_clamped := clampi(ref.diff, MIN_DIFF, MAX_DIFF)
	var base_weights: Array = DIFF_WEIGHTS_BY_PALIER[palier_clamped]
	var base_weight: float = base_weights[diff_clamped]
	
	var shift := performanceScore + float(Etape) * 0.25
	var modifier := maxf(0.1, 1.0 + shift * (float(diff_clamped) - 2.5) * 0.25)
	return base_weight * modifier


func chooseQuestion() -> bool:
	if refPool.is_empty():
		Question = null
		return false
	
	var weights: Array[float] = []
	var total_weight: float = 0.0
	
	for ref in refPool:
		var w := _get_question_weight(ref)
		weights.append(w)
		total_weight += w
	
	var roll := randf() * total_weight
	var cumul: float = 0.0
	var index_choisi: int = refPool.size() - 1
	
	for i in range(refPool.size()):
		cumul += weights[i]
		if roll <= cumul:
			index_choisi = i
			break
	
	Question = refPool[index_choisi]
	refPool.remove_at(index_choisi)
	historiqueRef.append(Question)
	return true


func mettreEnScene() -> void:
	fermerScene()
	groupHolder.show()
	textBar.text = ""
	textBar.grab_focus()
	
	if Question.isAudio:
		audioHolder.stream = Question.audio
		audioHolder.play()
	elif Question.isTexte:
		textHolder.text = Question.texte
		textHolder.show()
	elif Question.isVideo:
		videoHolder.stream = Question.video
		videoHolder.show()
		videoHolder.play()
	elif Question.isImage:
		imageHolder.texture = Question.image
		imageHolder.show()


func _on_text_submitted(submitted_text: String) -> void:
	if gamestate == State.QUIZ and Question != null:
		_verifier_reponse(submitted_text)


func _verifier_reponse(saisie: String) -> void:
	var reponse_joueur := _normaliser_texte(saisie)
	var reponse_attendue := _normaliser_texte(Question.ref)
	
	if reponse_joueur.is_empty():
		return
	
	var distance := _levenshtein_distance(reponse_joueur, reponse_attendue)
	var tolerance := _get_tolerance_fautes(reponse_attendue.length())
	
	if distance <= tolerance:
		bonneRep()
	else:
		mauvaiseRep()


func _normaliser_texte(texte: String) -> String:
	var res := texte.strip_edges().to_lower()
	var remplacements := {
		"à": "a", "â": "a", "ä": "a",
		"é": "e", "è": "e", "ê": "e", "ë": "e",
		"î": "i", "ï": "i",
		"ô": "o", "ö": "o",
		"ù": "u", "û": "u", "ü": "u",
		"ç": "c", "œ": "oe", "æ": "ae"
	}
	for accent in remplacements:
		res = res.replace(accent, remplacements[accent])
	return res


func _get_tolerance_fautes(longueur: int) -> int:
	if longueur <= 3:
		return 0
	elif longueur <= 7:
		return 1
	return 2


func _levenshtein_distance(s1: String, s2: String) -> int:
	var len1 := s1.length()
	var len2 := s2.length()
	
	if len1 == 0:
		return len2
	if len2 == 0:
		return len1
	
	var prev_row := PackedInt32Array()
	prev_row.resize(len2 + 1)
	for j in range(len2 + 1):
		prev_row[j] = j
	
	for i in range(1, len1 + 1):
		var curr_row := PackedInt32Array()
		curr_row.resize(len2 + 1)
		curr_row[0] = i
		var c1 := s1.unicode_at(i - 1)
		
		for j in range(1, len2 + 1):
			var c2 := s2.unicode_at(j - 1)
			var cost := 0 if c1 == c2 else 1
			curr_row[j] = mini(
				mini(curr_row[j - 1] + 1, prev_row[j] + 1),
				prev_row[j - 1] + cost
			)
		prev_row = curr_row
	
	return prev_row[len2]


func mauvaiseRep() -> void:
	_play_sfx(nope)
	presentateur.startDialog(pos.global_position, defaites[Question.diff])
	Question = null
	Vie -= 1
	Etape = 0
	performanceScore = clampf(performanceScore - 0.75, -1.5, 1.5)
	textBar.text = ""
	
	if Vie <= 0:
		_change_state(State.GAME_OVER)
	else:
		_change_state(State.QUIZ)


func bonneRep() -> void:
	_play_sfx(yes)
	presentateur.startDialog(pos.global_position, victoires[Question.diff])
	Question = null
	Etape += 1
	performanceScore = clampf(performanceScore + 0.25, -1.5, 1.5)
	
	if Etape >= QUESTIONS_PAR_PALIER:
		Etape = 0
		if Palier >= MAX_PALIER:
			_change_state(State.VICTORY)
		else:
			_change_state(State.CLEAR)
	else:
		_change_state(State.QUIZ)


func fermerScene() -> void:
	if audioHolder.playing:
		audioHolder.stop()
	if videoHolder.is_playing():
		videoHolder.stop()
	
	imageHolder.hide()
	textHolder.hide()
	videoHolder.hide()
	groupHolder.hide()


func _set_choice_buttons_visible(is_visible: bool) -> void:
	choiceButton1.visible = is_visible
	choiceButton2.visible = is_visible
	choiceButton3.visible = is_visible


func _update_money_ui() -> void:
	moneyDisplayer.text = " " + str(Money) + " $ | "+ str(Vie) +" ❤️"


func _play_sfx(stream: AudioStream) -> void:
	if sfx != null and stream != null:
		sfx.stream = stream
		sfx.play()




func _on_skip_focus_entered() -> void:
	_play_sfx(change)


func _on_skip_pressed() -> void:
	_play_sfx(nope)
	_change_state(State.PALIER)


func _on_vie_focus_entered() -> void:
	_play_sfx(change)


func _on_vie_pressed() -> void:
	if Money >= 10 :
		_play_sfx(yes)
		Money -= 10
		Vie += 1
		_change_state(State.PALIER)
		_update_money_ui()
	else:
		_play_sfx(nope)


func _on_roue_focus_entered() -> void:
	_play_sfx(change)
	

func _on_roue_pressed() -> void:
	pass # Replace with function body.


func _on_tree_exiting() -> void:
	presentateur.stopDialog()
