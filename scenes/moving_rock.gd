extends GenericRock

var MOVE_SPEED = 300
var direction = Vector2(1, 0)  # Starts moving left

# Called when the node enters the scene tree for the first time.
func _ready():
	NAME = "MovingRock"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Move the rock left or right
	var velocity = MOVE_SPEED * direction * delta
	var collision = move_and_collide(velocity)
	if collision and collision.get_collider():
		if collision.get_collider().is_in_group("walls"):
			direction.x *= -1  # Reverse direction
