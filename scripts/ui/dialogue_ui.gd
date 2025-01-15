extends Control

@onready var label : Label = $Label
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var choice_container : VBoxContainer = $VBoxContainer
@onready var choice_1 : Button = $VBoxContainer/Choice1
@onready var choice_2 : Button = $VBoxContainer/Choice2

var player : CharacterBody2D
var is_visible = false
var visible_characters = 0
var typing_speed = 0.04

signal typing_finished

func _ready():
	# Connect to existing signals
	DialogueManager.connect("dialogue_finished", on_dialogue_finished)
	
	# Connect to new choice signals
	DialogueManager.connect("choices_presented", on_choices_presented)
	DialogueManager.connect("choice_made", on_choice_made)
	
	# Connect button signals
	choice_1.pressed.connect(on_choice_1_pressed)
	choice_2.pressed.connect(on_choice_2_pressed)
	
	# Hide UI elements
	arrow_sprite.hide()
	choice_container.hide()
	hide()
	
	player = get_tree().get_first_node_in_group("Player")

func display_text(text: String, voice: String):
	DialogueManager.emit_signal("dialogue_started")
	SoundManager.play_sfx_sound("click_1")
	player.current_player_state = player.PlayerState.INTERACTING
	
	# Hide choices when displaying new text
	choice_container.hide()
	
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
	
	if not DialogueManager.waiting_for_choice:
		arrow_sprite.show()
		arrow_sprite.play("default")
	
	DialogueManager.is_typing = false
	DialogueManager.emit_signal("typing_finished")
	emit_signal("typing_finished")


func on_dialogue_finished():
	if is_visible:
		SoundManager.play_sfx_sound("click_1")
		
		arrow_sprite.hide()
		choice_container.hide()
		anim_player.play_backwards("dialogue_box_slide")
		await anim_player.animation_finished
		hide()
		is_visible = false
	
	label.text = ""
	player.current_player_state = player.PlayerState.IDLE

# Function to handle showing choices
func on_choices_presented(choices: Array):
	if choices.size() > 0:
		arrow_sprite.hide()
		choice_container.show()
		
		# Setup first choice
		choice_1.text = choices[0]["text"]
		choice_1.show()
		
		# Setup second choice if it exists
		if choices.size() > 1:
			choice_2.text = choices[1]["text"]
			choice_2.show()
		else:
			choice_2.hide()

# Handle choice button presses
func on_choice_1_pressed():
	if DialogueManager.waiting_for_choice:
		SoundManager.play_sfx_sound("click_1")
		choice_container.hide()
		DialogueManager.make_choice(0)

func on_choice_2_pressed():
	if DialogueManager.waiting_for_choice:
		SoundManager.play_sfx_sound("click_1")
		choice_container.hide()
		DialogueManager.make_choice(1)

# Handle choice made signal
func on_choice_made(_choice_index: int):
	arrow_sprite.hide()
	choice_container.hide()
