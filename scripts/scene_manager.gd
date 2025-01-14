extends Node2D

@export var tilemap : TileMapLayer
@export var player : CharacterBody2D

var old_player_position : Vector2
var player_position : Vector2

func _ready():
	old_player_position = player_position

func _physics_process(delta: float) -> void:
	player_position = player.position

func teleport_player(teleport_location: Vector2):
	var world_position = tilemap.map_to_local(teleport_location)
	print("Teleported to: ", teleport_location)
	player.position = world_position
	player.velocity = Vector2.ZERO
	player.move_and_slide()
