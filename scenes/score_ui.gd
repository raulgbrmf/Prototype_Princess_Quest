extends CanvasLayer

var current_height = 0
var max_height = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("initialize_height_label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_height()

func initialize_height_label():
	if is_instance_valid($Height): # Ensures that the node is valid
		$Height.text = "Height: " + str(current_height)
	else:
		print("Height label not found or not ready")

func get_current_height():
	return current_height

func get_max_height():
	return max_height

func set_current_height(value):
	current_height = value

func update_max_height(value):
	if value > max_height:
		max_height = value

func increase_current_height(value):
	current_height += value

func update_height():
	$Height.text = "Height " + str(get_current_height())
	
func play_song(name):
	if name == "MenuSong":
		pass
		#$FirstSong.play()
		

