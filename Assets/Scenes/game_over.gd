extends Node2D

@onready var sfx = $sfx
@onready var bgm = $bgm
@onready var ymg = $ymg

@export var yes = AudioStreamWAV
@export var change = AudioStreamWAV
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_focus_entered() -> void:
	sfx.stream = change
	sfx.play()
	


func _on_button_pressed() -> void:
	sfx.stream = yes
	sfx.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(preload("res://Assets/Scenes/MainMenu.tscn"));
