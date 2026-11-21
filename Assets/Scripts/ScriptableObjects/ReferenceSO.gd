extends Resource

class_name RefSO

@export_category("Type")
@export var isImage = false
@export var image : Texture2D = null

@export var isAudio = false
@export var audio : AudioStream = null

@export var isTexte = false
@export var texte : String = ""

@export var isVideo = false
@export var video : VideoStream = null

@export_category("Data")
@export var ref : String = ""
#@export var options : Array[String] = []
@export var tag1 = ""
@export var tag2 = ""
@export var diff : int = 0
