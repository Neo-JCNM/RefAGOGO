extends Resource

class_name RefsAudio

@export_group("Data")
@export var src : AudioStream
@export var ref : String = ""
@export var options : Array[String] = []
@export var tags : PackedStringArray = []
@export var diff : int = 0
