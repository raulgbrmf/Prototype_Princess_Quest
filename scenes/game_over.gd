extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreUI.visible = false
	$UI/AnimationPlayer.play("princess_show")
	$UI/Score.text = "your score: " + str(ScoreUI.get_current_height()) + " m"
	$UI/BestScore.text = "max score: " + str(ScoreUI.get_max_height()) + " m"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main_level.tscn")

