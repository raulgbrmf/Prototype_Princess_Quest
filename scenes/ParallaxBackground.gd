extends ParallaxBackground

const SCREEN_HEIGHT = 700

func _process(_delta):
	# Assuming the player moves up, we decrease the y value of the scroll_offset
	# This will make the background move down, giving the illusion that the player is moving up
	scroll_offset.y -= $"../Princess".JUMP_VELOCITY
	# Reset the y value of the scroll_offset to 0 if it's less than -SCREEN_HEIGHT to create the infinite loop
	if scroll_offset.y <= -SCREEN_HEIGHT:
		scroll_offset.y += SCREEN_HEIGHT
