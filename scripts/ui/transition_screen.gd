extends Control

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

signal screen_black
signal transition_completed

func _ready() -> void:
	# Make sure we can animate while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	color_rect.modulate.a = 1

func play_transition() -> void:
	visible = true
	
	# Reset the animation to start
	animation_player.stop()
	
	animation_player.play("circle_transition")
	await animation_player.animation_finished
	screen_black.emit()
	
	await get_tree().create_timer(1.0, true).timeout
	
	animation_player.play_backwards("circle_transition")
	await animation_player.animation_finished
	
	transition_completed.emit()
