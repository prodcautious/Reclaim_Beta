extends Node2D

@export var tilemap : TileMapLayer
@export var player : CharacterBody2D

var old_player_position : Vector2
var player_position : Vector2

func _ready():
	load_game_data()
	old_player_position = player_position

func _physics_process(delta: float) -> void:  # Fixed the function name
	player_position = player.position

func load_game_data() -> void:
	var save_data = SaveManager.load_game()
	if save_data.has("player"):
		var player_data = save_data.player
		if player_data.has("position"):
			var saved_position = Vector2(
				player_data.position.x,
				player_data.position.y
			)
			player.position = saved_position
			player.load_data(player_data)  # Load other player data
			print("Save successfully loaded")

func teleport_player(teleport_location: Vector2):
	var world_position = tilemap.map_to_local(teleport_location)
	print("Teleported to: ", teleport_location)
	player.position = world_position
	player.velocity = Vector2.ZERO
	player.move_and_slide()
