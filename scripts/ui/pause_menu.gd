# PauseMenu.gd
extends Control

var paused : bool = false
var controller_detected : bool = false
var no_controller_detected : bool = false
@onready var resume_button : Button = $CenterContainer/VBoxContainer/ResumeButton
var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	self.hide()
	# Connect to the dialogue signals
	DialogueManager.connect("dialogue_started", _on_dialogue_started)
	DialogueManager.connect("dialogue_finished", _on_dialogue_finished)

func _process(delta: float) -> void:
	if paused and not controller_detected:
		if len(Input.get_connected_joypads()) == 0:
			if !no_controller_detected:
				print("No controller detected.")
				no_controller_detected = true
		else:
			if no_controller_detected:
				print("Controller detected. Grabbing focus of first button.")
				print(Input.get_connected_joypads())
				resume_button.grab_focus()
				controller_detected = true
				no_controller_detected = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		# Check for states that should prevent pausing
		if player:
			if player.current_player_state == player.PlayerState.TELEPORTING:
				print("Cannot pause while teleporting.")
				return
			elif player.current_player_state == player.PlayerState.INTERACTING:
				print("Cannot pause during dialogue.")
				return
		
		if paused:
			resume_game()
		else:
			pause_game()

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_save_button_pressed() -> void:
	if player:
		SaveManager.save_game({
			"player": player.save_data()
		})

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func pause_game() -> void:
	if not player.current_player_state == player.PlayerState.INTERACTING:
		paused = true
		get_tree().paused = true
		self.show()
		print("Game paused.")

func resume_game() -> void:
	if paused:  # Only resume if we were actually paused
		paused = false
		controller_detected = false
		no_controller_detected = false
		get_tree().paused = false
		self.hide()
		print("Game resumed.")

func _on_dialogue_started() -> void:
	# Force unpause if dialogue starts
	if paused:
		resume_game()

func _on_dialogue_finished() -> void:
	# Ensure the game is unpaused when dialogue ends
	if get_tree().paused:
		get_tree().paused = false
