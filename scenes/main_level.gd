extends Node2D

# Constants
const PIXELS_PER_METER = 10
const SPAWN_BUFFER = 500
const CLEANUP_BUFFER = 2000
const ITEM_SPAWN_CHANCE = 0.10
const SCREEN_WIDTH = 600
const SCREEN_HEIGHT = 700
const MIDDLE_SCREEN_WIDTH = SCREEN_WIDTH / 2
const NUM_OF_ROCKS = 5
const WALL_LEFT_LIMIT_ROCKS = 70
const WALL_RIGHT_LIMIT_ROCKS = SCREEN_WIDTH - 70 

# Define the color thresholds
const COLOR_START = Color(0.53, 0.81, 0.92)  # Light blue
const COLOR_MID = Color(0.0, 0.0, 0.5)        # Dark blue
const COLOR_END = Color(0.0, 0.0, 0.0)        # Black

# Define the score thresholds for color changes
const SCORE_FOR_MID_COLOR = 200
const SCORE_FOR_END_COLOR = 400

# Preloaded scenes
var StaticRockScene = preload("res://scenes/floating_rock.tscn")
var MovingRockScene = preload("res://scenes/moving_rock.tscn")
var SpikyRockScene = preload("res://scenes/spiky_rock.tscn")
var PlantBoostScene = preload("res://scenes/plant_boost.tscn")
var InvisibleWallsScene = preload("res://scenes/invisible_walls.tscn")

# Spawn tracking
var next_rock_spawn_y = 500
var next_wall_spawn_y = 350

# Player's score and height tracking
var player_score = 0
var highest_reached_y = 0

@onready var color_rect = $ParallaxBackground/ParallaxLayer/ColorRect

func _ready():
	ScoreUI.visible = true
	highest_reached_y = $Princess.global_position.y
	ScoreUI.set_current_height(0) # Initial score update

func _process(_delta):
	var player_y = $Princess.global_position.y
	handle_spawning(player_y)
	check_player_death(player_y)
	cleanup_offscreen_objects(player_y)
	update_score(player_y)
	update_background_color(ScoreUI.get_current_height())

func update_background_color(current_score):
	var current_color
	if current_score < SCORE_FOR_MID_COLOR:
		# Interpolate between start and mid colors based on score
		var t = current_score / float(SCORE_FOR_MID_COLOR)
		current_color = COLOR_START.lerp(COLOR_MID, t)
	elif current_score < SCORE_FOR_END_COLOR:
		# Interpolate between mid and end colors based on score beyond the first threshold
		var t = (current_score - SCORE_FOR_MID_COLOR) / float(SCORE_FOR_END_COLOR - SCORE_FOR_MID_COLOR)
		current_color = COLOR_MID.lerp(COLOR_END, t)
	else:
		current_color = COLOR_END  # Once the end score is reached, the color remains black
	
	color_rect.color = current_color

func handle_spawning(player_y):
	if player_y < next_rock_spawn_y + int(SCREEN_HEIGHT/2):
		for num in NUM_OF_ROCKS:
			spawn_rocks()
			next_rock_spawn_y -= randf_range(220, 290)

	if player_y > next_wall_spawn_y:
		spawn_wall()
		next_wall_spawn_y -= SCREEN_HEIGHT

func spawn_rocks():
	var rock_instance = choose_rock_instance()
	rock_instance.global_position = Vector2(randf_range(WALL_LEFT_LIMIT_ROCKS, WALL_RIGHT_LIMIT_ROCKS), next_rock_spawn_y)
	$RocksContainer.add_child(rock_instance)  # Add to the RocksContainer
	if should_spawn_item() and rock_instance.NAME != "MovingRock":
		spawn_item(rock_instance)

func choose_rock_instance():
	match randi() % 3:
		0:
			return StaticRockScene.instantiate()
		1:
			return MovingRockScene.instantiate()
		2:
			var instance = SpikyRockScene.instantiate()
			instance.connect("player_hurt", handle_player_death)
			return instance

func should_spawn_item():
	return randf() < ITEM_SPAWN_CHANCE

func spawn_item(parent):
	var item_instance = PlantBoostScene.instantiate()
	item_instance.global_position = Vector2(0, -48) # Adjust based on the item's collision shape extents
	item_instance.connect("item_collected", super_jump)
	parent.add_child(item_instance)

func spawn_wall():
	var wall_instance = InvisibleWallsScene.instantiate()
	wall_instance.global_position = Vector2(MIDDLE_SCREEN_WIDTH, next_wall_spawn_y)
	wall_instance.add_to_group("walls")
	$WallsContainer.add_child(wall_instance)

func cleanup_offscreen_objects(player_y):
	for rock in $RocksContainer.get_children():
		if rock.global_position.y > player_y + CLEANUP_BUFFER:
			rock.queue_free()
	for wall in $WallsContainer.get_children():
		if wall.global_position.y > player_y + CLEANUP_BUFFER:
			wall.queue_free()

func check_player_death(player_y):
	var dead_zone_y = $Camera2D.global_position.y + int(SCREEN_HEIGHT / 2)
	if player_y > dead_zone_y:
		handle_player_death()

func update_score(player_y):
	if player_y < highest_reached_y:
		var height_difference = highest_reached_y - player_y
		var score_increase = int(height_difference / PIXELS_PER_METER)
		ScoreUI.increase_current_height(score_increase)
		highest_reached_y = player_y

func update_max_score(value):
	ScoreUI.update_max_height(value)

func handle_player_death():
	if not $Princess.is_dead and not $Princess.is_invulnerable:
		update_max_score(ScoreUI.get_current_height())
		$Princess._handle_death()

func super_jump():
	$Princess.JUMP_VELOCITY = -1200
	$Princess.jump_counter = 0
	$Princess.is_invulnerable = true
	$Princess/SuperJumpTimer.start()

func _on_super_jump_timer_timeout():
	$Princess.JUMP_VELOCITY = -750


func _on_princess_game_over():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
