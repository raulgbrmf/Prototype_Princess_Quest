extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreUI.play_song("MenuSong")
	$UI/ParallaxBackground/ParallaxLayer/ColorRect.color = Color(0.53, 0.81, 0.92)
	ScoreUI.visible = false
	$UI/Princess.can_move = false
	$UI/Princess.JUMP_VELOCITY = -550

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main_level.tscn")
