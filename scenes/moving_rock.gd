extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$MovingRockAnimatable/AnimationPlayer.play("move_left_and_right")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
