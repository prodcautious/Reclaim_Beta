extends Area2D

enum InteractType { DIALOGUE, TELEPORT, SAVE }
enum Direction { LEFT, RIGHT, UP, DOWN }
enum TransitionType { CIRCLE }

@export_category("Main")
@export var collision_size : Vector2
@export var interact_type : InteractType = InteractType.TELEPORT
@export var direction : Direction = Direction.UP
@export_category("If InteractType.TELEPORT")
@export var transition_type : TransitionType = TransitionType.CIRCLE
@export var teleport_location : Vector2
@export_category("If InteractType.DIALOGUE")
@export var dialogue_id: String


func _ready():
	var collision = RectangleShape2D.new()
	collision.size = collision_size
	$CollisionShape2D.shape = collision

func interact() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if interact_type == InteractType.TELEPORT:
		if direction == player.current_player_direction:
			var transition_screen = get_tree().get_first_node_in_group("TransitionScreen")
			
			if transition_screen == null:
				print("Error: TransitionScreen not found!")
				return

			# Put player in teleport state
			player.start_teleport()
			
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
			await get_tree().create_timer(0.1, true).timeout
			get_tree().paused = true
	if interact_type == InteractType.DIALOGUE:
		if direction == player.current_player_direction and not DialogueManager.is_typing and not DialogueManager.waiting_for_choice:
			DialogueManager.start_dialogue(dialogue_id)


func _on_screen_black():
	var scene_manager = get_tree().root.get_node("SceneManager")
	scene_manager.teleport_player(teleport_location)

func _on_transition_completed():
	get_tree().paused = false
	#Reset Player State
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.end_teleport()  # Reset teleport state
	# Clean up signals
	var transition_screen = get_tree().get_first_node_in_group("TransitionScreen")
	if transition_screen and transition_screen.is_connected("screen_black", _on_screen_black):
		transition_screen.disconnect("screen_black", _on_screen_black)
	if transition_screen and transition_screen.is_connected("transition_completed", _on_transition_completed):
		transition_screen.disconnect("transition_completed", _on_transition_completed)
