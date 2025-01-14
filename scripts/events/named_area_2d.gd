extends Area2D

@export var area_name : String
@export var collision_size : Vector2

func _ready():
	var collision = RectangleShape2D.new()
	collision.size = collision_size
	$CollisionShape2D.shape = collision

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("Player"):
		body.current_location = area_name
