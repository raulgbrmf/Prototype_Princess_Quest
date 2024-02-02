extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -750.0
var is_jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimationPlayer.connect("animation_finished", Callable(_on_animation_player_animation_finished))

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	_jump(delta,direction)
	_handle_movement(delta,direction)
	move_and_slide()


func _jump(delta,direction):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		if direction == -1:
			$AnimationPlayer.play("jump_left")
		elif direction == 1:
			$AnimationPlayer.play("jump_right")
		elif direction == 0:
			$AnimationPlayer.play("jump")
		
func _handle_movement(delta,direction):
	if direction:
		velocity.x = direction * SPEED
		_sprite_direction(direction)
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
