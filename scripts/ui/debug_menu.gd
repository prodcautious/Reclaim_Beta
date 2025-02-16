extends Control

@onready var fps_label : Label = $MarginContainer/VBoxContainer/FPSLabel
@onready var player_pos_label : Label = $MarginContainer/VBoxContainer/PlayerPosLabel
@onready var player_state_label : Label = $MarginContainer/VBoxContainer/PlayerStateLabel
@onready var direction_label : Label = $MarginContainer/VBoxContainer/DirectionLabel
@onready var location_label : Label = $MarginContainer/VBoxContainer/LocationLabel

var debug : bool = false
var scene_manager : Node = null
var player : CharacterBody2D = null

func _ready():
	self.hide()
	scene_manager = get_tree().root.get_node("SceneManager")
	player = get_tree().get_first_node_in_group("Player")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		if debug:
			debug = false
			self.hide()
			print("Debug closed.")
		elif !debug:
			debug = true
			self.show()
			print("Debug opened.")

func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	player_pos_label.text = "Position: " + str(Vector2i(scene_manager.player_position / 32))
	var state_names = {
		player.PlayerState.IDLE: "IDLE",
		player.PlayerState.INTERACTING: "INTERACTING",
		player.PlayerState.TELEPORTING: "TELEPORTING",
		player.PlayerState.WALKING: "WALKING",
	}
	player_state_label.text = "State: " + state_names[player.current_player_state]
	var direction_names = {
		player.Direction.LEFT: "LEFT",
		player.Direction.RIGHT: "RIGHT",
		player.Direction.UP: "UP",
		player.Direction.DOWN: "DOWN"
	}
	direction_label.text = "Direction: " + direction_names[player.current_player_direction]
	location_label.text = "Location: " + player.current_location
