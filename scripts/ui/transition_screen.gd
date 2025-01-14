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
	print("Starting transition")
	visible = true
	
	# Reset the animation to start
	animation_player.stop()
	
	print("Playing fade to black")
	animation_player.play("circle_transition")
	await animation_player.animation_finished
	
	print("Screen is black, emitting signal")
	screen_black.emit()
	
	await get_tree().create_timer(1.0, true).timeout
	
	print("Playing fade back in")
	animation_player.play_backwards("circle_transition")
	await animation_player.animation_finished
	
	print("Transition complete")
	transition_completed.emit()
