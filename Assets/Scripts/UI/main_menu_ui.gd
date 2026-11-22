extends Control

@export var next = preload("res://Assets/Scenes/Jeu.tscn");

@export var sfx : AudioStreamPlayer = null
@export var bgm : AudioStreamPlayer = null

@export_category("Sound Design")

@export var nope : AudioStreamWAV = null
@export var yes : AudioStreamWAV = null
@export var change : AudioStreamWAV = null

@export var intro : AudioStreamMP3 = null
@export var loop : AudioStreamMP3 = null





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bgm.set_stream(intro)
	bgm.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(not bgm.playing):
		bgm.set_stream(loop)
		bgm.play()


func _on_quit_btn_button_down() -> void:
	sfx.set_stream(nope)
	sfx.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()


func _on_start_btn_button_down() -> void:
	if next != null :
		sfx.set_stream(yes)
		sfx.play()
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_packed(next);
		


func _on_start_btn_focus_entered() -> void:
	sfx.set_stream(change)
	sfx.play()


func _on_quit_btn_focus_entered() -> void:
	sfx.set_stream(change)
	sfx.play()
