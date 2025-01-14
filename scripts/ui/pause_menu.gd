extends Control

var paused : bool = false
var controller_detected : bool = false
var no_controller_detected : bool = false
@onready var resume_button : Button = $CenterContainer/VBoxContainer/ResumeButton
var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	self.hide()

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
	else:
		pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if paused:
			paused = false
			controller_detected = false
			no_controller_detected = false
			get_tree().paused = false
			self.hide()
			print("Game resumed.")
		elif !paused:
			paused = true
			get_tree().paused = true
			self.show()
			print("Game paused.")

func _on_resume_button_pressed() -> void:
	paused = false
	controller_detected = false
	no_controller_detected = false
	get_tree().paused = false
	self.hide()
	print("Game Resumed")


func _on_save_button_pressed() -> void:
	if player:
		SaveManager.save_game({
			"player": player.save_data()
		})


func _on_quit_button_pressed() -> void:
	get_tree().quit()
