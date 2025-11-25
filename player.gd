extends CharacterBody2D

@export var speed = 100.0

# Get references to the nodes
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D

var can_move = true

func _physics_process(_delta):
	if can_move:
	# 1. GET INPUT
		var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
		
		# 2. MOVE
		if direction:
			velocity = direction * speed
			# If moving, update animation
			update_animation(direction)
		else:
			velocity = Vector2.ZERO
			# If stopped, stop the animation or play an idle one
			anim_player.play("idle")
			# If you have an idle animation, use: anim_player.play("idle")

		move_and_slide()
	else:
		anim_player.play("idle")

# 3. Add this specific function so the Dialogue Box can call it
func set_move_state(state: bool):
	can_move = state
# 3. ANIMATION LOGIC
func update_animation(dir):
	# Priority to Horizontal movement (Left/Right)
	if dir.x != 0:
		anim_player.play("walk")
		
		# FLIP LOGIC:
		# If moving left (x < 0), flip the sprite. 
		# If moving right (x > 0), unflip it.
		if dir.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
	# Vertical movement
	elif dir.y < 0:
		anim_player.play("walk up")
	elif dir.y > 0:
		anim_player.play("walk down")
