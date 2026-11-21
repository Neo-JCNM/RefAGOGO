extends Control

@export var next : Node = null;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_btn_button_down() -> void:
	get_tree().quit()


func _on_start_btn_button_down() -> void:
	if next != null :
		get_tree().change_scene_to_node(next);
