extends Camera2D

var highest_y_position := INF  # Initialize with infinity so any position will be lower
const NAME = "Camera"

func _ready():
	# Assuming Princess is the name of the node and it is a direct child of the level
	# You might need to adjust the path based on your scene tree
	highest_y_position = $"../Princess".global_position.y

func _process(_delta):
	var princess_position = $"../Princess".global_position.y

	# Update the highest position reached by the princess
	if princess_position < highest_y_position:
		highest_y_position = princess_position
		# Move the camera up to the new highest position
		global_position.y = highest_y_position

	# Optionally, you can clamp the camera's lowest position
	# to prevent it from showing areas below the intended level bounds
	# global_position.y = max(global_position.y, some_minimum_y_value)
