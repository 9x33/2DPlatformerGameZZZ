extends CharacterBody2D

@export var speed: float = 10.0
@export var jump_power: float = 10.0
@export var attacking: bool = false

var speed_multiplier: float = 5.0
var jump_multiplier: float = -20.0
var direction: float = 0.0

@onready var locomotion_anim: AnimationPlayer = $AnimationPlayer      # run/idle/jump
@onready var attack_anim:     AnimationPlayer = $AnimationPlayer2     # attack only
@onready var sprite: Sprite2D = $Sprite2D

var vida_max: int = 10
var vida: int = vida_max

func _ready() -> void:
	# When the attack clip ends, clear the flag
	if not attack_anim.animation_finished.is_connected(_on_attack_finished):
		attack_anim.animation_finished.connect(_on_attack_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack()

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement input
	direction = Input.get_axis("move_left", "move_right")

	# Jump (blocked during attack; remove "and not attacking" to allow jump while attacking)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not attacking:
		velocity.y = jump_power * jump_multiplier

	# Horizontal movement
	if attacking:
		# optional: reduce sliding during attack
		velocity.x = move_toward(velocity.x, 0.0, speed * speed_multiplier * delta)
	else:
		if abs(direction) > 0.0:
			velocity.x = direction * speed * speed_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * speed_multiplier * delta)

	flip(direction)
	animate(direction)
	move_and_slide()

func attack() -> void:
	# Play attack on the second AnimationPlayer
	if attack_anim.has_animation("attack") and not attacking:
		attacking = true
		# pause/stop locomotion while attacking so it won't override
		if locomotion_anim.is_playing():
			locomotion_anim.stop()
		attack_anim.play("attack")

func animate(direction: float) -> void:
	# Don't change locomotion while attacking
	if attacking:
		return

	if not is_on_floor():
		if locomotion_anim.has_animation("jump"):
			locomotion_anim.play("jump")
		else:
			locomotion_anim.play("run")
	else:
		if abs(direction) > 0.1:
			locomotion_anim.play("run")
		else:
			locomotion_anim.play("idle")

func flip(direction: float) -> void:
	if direction < 0.0:
		sprite.flip_h = true
	elif direction > 0.0:
		sprite.flip_h = false

func _on_attack_finished(name: StringName) -> void:
	if name == "attack":
		attacking = false
