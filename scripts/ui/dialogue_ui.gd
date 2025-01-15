# DialogueUI.gd
extends Control

@onready var label : Label = $Label
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite : AnimatedSprite2D = $AnimatedSprite2D
var player : CharacterBody2D
var is_visible = false
var visible_characters = 0
var typing_speed = 0.04

func _ready():
	DialogueManager.connect("dialogue_finished", on_dialogue_finished)
	arrow_sprite.hide()
	hide()
	player = get_tree().get_first_node_in_group("Player")

func display_text(text: String, voice: String):
	DialogueManager.emit_signal("dialogue_started")
	SoundManager.play_sfx_sound("click_1")
	player.current_player_state = player.PlayerState.INTERACTING
	
	if not is_visible:
		show()
		anim_player.play("dialogue_box_slide")
		await anim_player.animation_finished
		is_visible = true
	
	arrow_sprite.hide()
	visible_characters = 0
	label.visible_characters = 0
	label.text = text
	while visible_characters < text.length():
		visible_characters += 1
		label.visible_characters = visible_characters
		SoundManager.play_dialogue_sound(voice)
		await get_tree().create_timer(typing_speed).timeout
	
	arrow_sprite.show()
	arrow_sprite.play("default")
	
	DialogueManager.is_typing = false
	DialogueManager.emit_signal("typing_finished")

func on_dialogue_finished():
	if is_visible:
		SoundManager.play_sfx_sound("click_1")
		
		arrow_sprite.hide()
		anim_player.play_backwards("dialogue_box_slide")
		await anim_player.animation_finished
		hide()
		is_visible = false
	label.text = ""
	player.current_player_state = player.PlayerState.IDLE
