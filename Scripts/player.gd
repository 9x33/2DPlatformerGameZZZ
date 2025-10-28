extends CharacterBody2D


const SPEED = 600.0
const JUMP_VELOCITY = -600.0


@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var vida_max: int = 10
var vida: int = vida_max


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	flip(direction)
	animate(direction)
	move_and_slide()

func animate(direction) -> void:
	if not is_on_floor():
		if animation.has_animation("jump"):
			animation.play("jump")
		else:
			animation.play("run")
	else:
		if abs(direction) > 0.1:
			animation.play("run")
		else:
			animation.play("idle")


func flip(direction) -> void:
	if direction < 0.0:
		sprite.flip_h = true
	elif direction > 0.0:
		sprite.flip_h = false
