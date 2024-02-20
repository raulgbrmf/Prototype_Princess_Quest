extends Node2D

signal item_collected
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_area_2d_body_entered(_body):
	item_collected.emit()
	queue_free()
