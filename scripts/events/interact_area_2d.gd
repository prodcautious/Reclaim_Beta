extends Area2D

enum InteractType { DIALOGUE, TELEPORT, SAVE }
enum Direction { LEFT, RIGHT, UP, DOWN }
enum TransitionType { CIRCLE }

@export var collision_size : Vector2
@export var interact_type : InteractType = InteractType.TELEPORT
@export var direction : Direction = Direction.UP
@export var transition_type : TransitionType = TransitionType.CIRCLE
@export var teleport_location : Vector2

func _ready():
	var collision = RectangleShape2D.new()
	collision.size = collision_size
	$CollisionShape2D.shape = collision

func interact() -> void:
	if interact_type == InteractType.TELEPORT:
		var player = get_tree().get_first_node_in_group("Player")
		
		if direction == player.current_player_direction:
			var transition_screen = get_tree().get_first_node_in_group("TransitionScreen")
			
			if transition_screen == null:
				print("Error: TransitionScreen not found!")
				return
				
			
			# Disconnect existing signals first
			if transition_screen.is_connected("screen_black", _on_screen_black):
				transition_screen.disconnect("screen_black", _on_screen_black)
			if transition_screen.is_connected("transition_completed", _on_transition_completed):
				transition_screen.disconnect("transition_completed", _on_transition_completed)
			
			# Connect new signals
			transition_screen.screen_black.connect(_on_screen_black)
			transition_screen.transition_completed.connect(_on_transition_completed)
			
			# Start transition before pausing
			transition_screen.play_transition()
			# Small delay to ensure transition starts
			await get_tree().create_timer(0.1, true).timeout
			get_tree().paused = true

func _on_screen_black():
	var scene_manager = get_tree().root.get_node("SceneManager")
	scene_manager.teleport_player(teleport_location)

func _on_transition_completed():
	get_tree().paused = false
	
	# Clean up signals
	var transition_screen = get_tree().get_first_node_in_group("TransitionScreen")
	if transition_screen and transition_screen.is_connected("screen_black", _on_screen_black):
		transition_screen.disconnect("screen_black", _on_screen_black)
	if transition_screen and transition_screen.is_connected("transition_completed", _on_transition_completed):
		transition_screen.disconnect("transition_completed", _on_transition_completed)
