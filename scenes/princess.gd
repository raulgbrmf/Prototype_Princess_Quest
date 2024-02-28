extends CharacterBody2D

const NAME = "Princess"
const SPEED = 300.0
var JUMP_VELOCITY = -750.0
var is_jumping = false
var is_dead = false
var can_move = true
var is_invulnerable = false
var jump_counter = 0

signal game_over

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass
	#$AnimationPlayer.connect("animation_finished", Callable(_on_animation_player_animation_finished))

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	_jump(delta,direction)
	_handle_movement(delta,direction)
	move_and_slide()


func _jump(delta,direction):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		_handle_invulnerability()
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		if direction == -1:
			$AnimationPlayer.play("jump_left")
		elif direction == 1:
			$AnimationPlayer.play("jump_right")
		elif direction == 0:
			$AnimationPlayer.play("jump")
		

func _handle_invulnerability():
	if jump_counter == 2:
		is_invulnerable = false
		jump_counter = 0
	else:
		jump_counter += 1
	

func _handle_movement(_delta,direction):
	if direction and not is_dead and can_move:
		velocity.x = direction * SPEED
		_sprite_direction(direction)
	elif is_dead:
		velocity.y = 0
		velocity.x = 0
	elif can_move == false:
		pass
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _sprite_direction(direction):
	if is_jumping:
		return  # Não faz nada se estiver pulando
	if direction == -1:
		$Sprite2D.frame = 2
	elif direction == 1:
		$Sprite2D.frame = 1
	if direction == 0:
		$Sprite2D.frame = 0
	

func _wait(timesec:float):
	var timer = get_tree().create_timer(timesec)
	await timer.timeout

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "jump_left" or anim_name == "jump_right" or anim_name == "jump":
		is_jumping = false
	elif anim_name == "Death":
		game_over.emit()

func _handle_death():
	is_dead = true
	$AnimationPlayer.play("Death")
