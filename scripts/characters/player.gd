extends CharacterBody2D

# Export variables
@export var movement_speed : float = 100.0
@export var current_health : float = 3.0
@export var max_health : float = 3.0

enum PlayerState {
	IDLE,
	INTERACTING,
	WALKING
}

var current_player_state : PlayerState = PlayerState.IDLE
var previous_player_state : PlayerState = PlayerState.IDLE

# Onready variables
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var player_interact_radius: Area2D = $PlayerInteractArea2D

# Direction variables
enum Direction { LEFT, RIGHT, UP, DOWN }
var current_player_direction : Direction = Direction.LEFT

# Interaction variables
@onready var interaction_area : Area2D = $PlayerInteractArea2D
@export var interact_radius = 5.0

func _ready():
	var collision = CircleShape2D.new()
	collision.radius = interact_radius
	$PlayerInteractArea2D/CollisionShape2D.shape = collision

# Play animations based on state and direction
func update_animation():
	if current_player_state == PlayerState.WALKING:
		match current_player_direction:
			Direction.LEFT:
				animated_sprite.play("walk_Left")
			Direction.RIGHT:
				animated_sprite.play("walk_Right")
			Direction.UP:
				animated_sprite.play("walk_Up")
			Direction.DOWN:
				animated_sprite.play("walk_Down")
	elif current_player_state == PlayerState.IDLE:
		match current_player_direction:
			Direction.LEFT:
				animated_sprite.play("idle_Left")
			Direction.RIGHT:
				animated_sprite.play("idle_Right")
			Direction.UP:
				animated_sprite.play("idle_Up")
			Direction.DOWN:
				animated_sprite.play("idle_Down")

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * movement_speed

	# Update player state
	if input_direction != Vector2.ZERO:
		current_player_state = PlayerState.WALKING
	else:
		current_player_state = PlayerState.IDLE

	# Update player direction
	if input_direction.x < 0:
		current_player_direction = Direction.LEFT
	elif input_direction.x > 0:
		current_player_direction = Direction.RIGHT
	elif input_direction.y < 0:
		current_player_direction = Direction.UP
	elif input_direction.y > 0:
		current_player_direction = Direction.DOWN

	update_animation()
	move_and_slide() # Pass the velocity explicitly

# Interaction Handling
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var overlapping = interaction_area.get_overlapping_areas()
		if overlapping.size() > 0:
			var closest = get_closest_interactable(overlapping)
			if closest.has_method("interact"):
				closest.interact()

# Check if the player is near an interactable object
func get_closest_interactable(areas):
	var min_distance = INF
	var closest = null
	for area in areas:
		if area.is_in_group("Interactable"):
			var distance = global_position.distance_to(area.global_position)
			if distance < min_distance:
				min_distance = distance
				closest = area
	return closest
