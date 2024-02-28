extends Node2D

# Ratio of pixels to meters.
const PIXELS_PER_METER = 10

# Preload rock scenes, plant and invisible walls
var static_rock = preload("res://scenes/floating_rock.tscn")
var moving_rock = preload("res://scenes/moving_rock.tscn")
var spiky_rock = preload("res://scenes/spiky_rock.tscn")
var plant_boost = preload("res://scenes/plant_boost.tscn")
var invisible_walls = preload("res://scenes/invisible_walls.tscn")


# Initial spawn position for the first rock
var spawn_position = 500 
var last_spawn_position = 500

# Initial spawn position for the first wall
var wall_spawn_position = 350
var wall_last_spawn_position = 350

# score variables
var score = 0
var highest_position = 0

func _ready():
	# Initialize the highest position at the start of the game
	highest_position = $Princess.global_position.y
	ScoreUI.set_current_height(0) # Initial score update

func _process(_delta):
	var player_position = $Princess.global_position.y
	var viewport_height = get_viewport_rect().size.y
	var dead_zone_position = $Camera2D.global_position.y + viewport_height/2
	if player_position < spawn_position + viewport_height/2: # Check if close to last spawn position. I ised viewport_height/2 to make the player dont see the rock spawning
		spawn_elements(5)
	
	if player_position < wall_last_spawn_position:
		spawn_walls()
		wall_last_spawn_position = $Princess.global_position.y
	
	# Check if the player has fallen into the dead zone
	if player_position > dead_zone_position:
		# Here, we assume you have a function to handle the player's death
		handle_player_death()
	
	cleanup_rocks()
	update_score_based_on_player_position()

func spawn_elements(number_of_rocks):
	print("ROCK SPAWN")
	for number in number_of_rocks:
		var rock_type = randi() % 3 # Randomly choose between 0, 1, and 2
		var rock_instance
		var should_spawn_item = false # Flag to determine whether an item should be spawned
		match rock_type:
			0:
				rock_instance = static_rock.instantiate()
				should_spawn_item = true # Set flag to spawn item for floating rock
			1:
				rock_instance = moving_rock.instantiate()
				# Here you can leave should_spawn_item as false if you don't want items on moving rocks
			2:
				rock_instance = spiky_rock.instantiate()
				rock_instance.connect("player_hurt", handle_player_death)
				should_spawn_item = true # Set flag to spawn item for spiky rock
		
		rock_instance.global_position = Vector2(randf_range(70, 540), spawn_position)
		add_child(rock_instance)
		spawn_position -= randf_range(220, 290) # Adjust for desired spacing between rocks
		
		# Now decide if an item should spawn
		if randf() < 0.15 and should_spawn_item: # 20% chance to spawn an item, adjust this as needed
			var plant_boost_instance = plant_boost.instantiate()
			#var item_position_offset = Vector2(0, -80) # Assuming your rock scenes have a method get_item_spawn_offset that returns the appropriate y offset
			plant_boost_instance.global_position = Vector2(0, -48) # Adjust the y offset based on the item's collision shape extents
			plant_boost_instance.connect("item_collected", super_jump)
			rock_instance.add_child(plant_boost_instance)

func spawn_walls():
	#print("WALL SPAWN")
	var wall_instance = invisible_walls.instantiate()
	var middle_screen = 300 # supposing the screen has 600 pixel of width
	wall_instance.global_position = Vector2(middle_screen, spawn_position)
	add_child(wall_instance)
	wall_spawn_position -= 700 # supposing the screen has 700 of height (Must turn into a parameter for the final version)


func cleanup_rocks():
	for rock in get_children():
		# Assuming the camera follows the player and the game is vertical
		# Adjust these values according to your game's camera height and player jump height
		if rock.global_position.y > $Princess.global_position.y + 600:
			#print("Cleaning a rock")
			rock.queue_free()
 
func handle_player_death():
	# This is where you would put your game over logic
	#$Princess.queue_free() # Remove the player from the scene
	if $Princess.is_dead == false and not $Princess.is_invulnerable:
		$Princess._handle_death()
	# You could also transition to a game over screen or restart the level

func super_jump():
	$Princess.JUMP_VELOCITY = -1200.0
	$Princess.jump_counter = 0 # This way it prevents the player dies if catches one more item while super jumping
	$Princess.is_invulnerable = true
	$Princess/SuperJumpTimer.start()
	

func _on_super_jump_timer_timeout():
	$Princess.JUMP_VELOCITY = -750.0
	
func update_score_based_on_player_position():
	var current_position = $Princess.global_position.y
	if current_position < highest_position:
		# Calculate the difference in pixels.
		var pixel_difference = highest_position - current_position
		# Convert the pixel difference to meters using the defined ratio.
		var meter_difference = pixel_difference / PIXELS_PER_METER
		# Normalize the difference to an integer if needed.
		var normalized_difference = int(meter_difference)
		# Update the score using the normalized difference.
		ScoreUI.increase_current_height(normalized_difference)
		# Update the highest position.
		highest_position = current_position
