extends Node

# Dictionary storing all dialogue data with structure:
# - window_1, door_1, etc: Dialogue event IDs
# - type: "sequential" (changes based on # of triggers) or "normal" (always same) or "choice" (Self explanatory LOL)
# - messages: Array of dialogue messages with text and voice type
var dialogue_data = {
	"weeping_woods_trees": {
		"type": "sequential",
		"messages": [
			{
				"text": "You peer into the densely layered trees.",
				"voice": "voice_1"
			},
			{
				"text": "Kinda spooky, huh?",
				"voice": "voice_1"
			}
		]
	},
	"some_choice": {
		"type": "choice",
		"messages": [
			{"text": "What will you do?", "voice": "voice_1"}
		],
		"choices": [
			{"text": "Option A", "next_dialogue": "result_a"},
			{"text": "Option B", "next_dialogue": "result_b"}
		]
	},
	"result_a": {
		"type": "normal",
		"messages": [
			{"text": "Cool, I respect that", "voice": "voice_1"}
		]
	},
	"result_b": {
		"type": "normal",
		"messages": [
			{"text": "Not super cool of you man.", "voice": "voice_1"}
		]
	},
	"weeping_woods_window": {
		"type": "sequential",
		"messages": [
			{
				"text": "Sigh... Didn't we talk about this in the last demo?",
				"voice": "voice_1"
			},
			{
				"text": "No more voyeurism.",
				"voice": "voice_1"
			}
		]
	},
	"weeping_woods_tree_carving": {
		"type": "normal",
		"messages": [
			{
				"text": "The tree is etched with a heart and two initials, reading 'K + N.'",
				"voice": "voice_1"
			},
		]
	},
	"npc_1": {
		"type": "normal",
		"messages": [
			{
				"text": "Hello traveler!",
				"voice": "voice_1"
			},
			{
				"text": "Beautiful day isn't it?",
				"voice": "voice_1"
			}
		]
	}
}

# System state variables
var dialogue_active = false
var current_dialogue = []
var dialogue_index = 0
var is_typing = false
var dialogue_state = {}
var current_choices = []  # Store current available choices
var waiting_for_choice = false  # Track if waiting for player choice

# Signals for event handling
signal dialogue_started
signal dialogue_finished
signal typing_finished
signal choices_presented(choices)  # New signal for choice presentation
signal choice_made(choice_index)   # New signal for choice selection

func _ready():
	for dialogue_id in dialogue_data.keys():
		if dialogue_data[dialogue_id]["type"] == "sequential":
			dialogue_state[dialogue_id] = {
				"times_triggered": 0
			}

func start_dialogue(dialogue_id: String):
	if not dialogue_active:
		if dialogue_data.has(dialogue_id):
			var dialogue = dialogue_data[dialogue_id]
			
			match dialogue["type"]:
				"sequential":
					handle_sequential_dialogue(dialogue_id)
				"choice":
					handle_choice_dialogue(dialogue_id)
				_:
					handle_normal_dialogue(dialogue_id)
		else:
			print("Dialogue ID not found: " + dialogue_id)
	elif not is_typing and not waiting_for_choice:
		show_next_line()

# Handle sequential dialogues that change based on number of triggers
func handle_sequential_dialogue(dialogue_id: String):
	var dialogue = dialogue_data[dialogue_id]
	var state = dialogue_state[dialogue_id]
	var messages = dialogue["messages"]
	
	# Select message based on trigger count
	if state["times_triggered"] == 0:
		current_dialogue = [messages[0]]
	# Second and subsequent triggers use the second message
	elif state["times_triggered"] == 1:
		current_dialogue = [messages[1]]
	else:
		current_dialogue = [messages[1]]
	
	state["times_triggered"] += 1
	dialogue_index = 0
	dialogue_active = true
	show_next_line()

# Handle normal dialogues that always show the same messages
func handle_normal_dialogue(dialogue_id: String):
	current_dialogue = dialogue_data[dialogue_id]["messages"]
	dialogue_index = 0
	dialogue_active = true
	show_next_line()

# Function to handle choice dialogues
func handle_choice_dialogue(dialogue_id: String):
	var dialogue = dialogue_data[dialogue_id]
	current_dialogue = dialogue["messages"]
	current_choices = dialogue["choices"]
	dialogue_index = 0
	dialogue_active = true
	show_next_line()

# Display next line in current dialogue sequence
func show_next_line():
	if dialogue_index < current_dialogue.size():
		is_typing = true
		display_text(current_dialogue[dialogue_index].text, current_dialogue[dialogue_index].voice)
		await get_tree().get_first_node_in_group("DialogueUI").typing_finished
		dialogue_index += 1
		
		# If this is a choice dialogue and it's shown all messages, present choices
		var current_dialogue_id = get_current_dialogue_id()
		if dialogue_data.has(current_dialogue_id) and dialogue_data[current_dialogue_id]["type"] == "choice" and dialogue_index >= current_dialogue.size():
			present_choices()
	else:
		if not waiting_for_choice:
			dialogue_active = false
			is_typing = false
			emit_signal("dialogue_finished")
			print("Dialogue finished.")

# New function to present choices to the player
func present_choices():
	waiting_for_choice = true
	emit_signal("choices_presented", current_choices)

# Function to handle player choice selection
func make_choice(choice_index: int):
	if waiting_for_choice and choice_index < current_choices.size():
		waiting_for_choice = false
		emit_signal("choice_made", choice_index)
		
		# Start the next dialogue based on the choice
		var next_dialogue = current_choices[choice_index]["next_dialogue"]
		dialogue_active = false  # Reset dialogue state before starting new dialogue
		if next_dialogue and dialogue_data.has(next_dialogue):
			start_dialogue(next_dialogue)
		else:
			emit_signal("dialogue_finished")

# Helper function to get current dialogue ID
func get_current_dialogue_id() -> String:
	for dialogue_id in dialogue_data.keys():
		if dialogue_data[dialogue_id]["messages"] == current_dialogue:
			return dialogue_id
	return ""

# Find dialogue UI node in scene tree
func find_dialogue_box() -> Node:
	var nodes = get_tree().get_nodes_in_group("DialogueUI")
	if nodes.size() > 0:
		return nodes[0]
	return null

# Send text to dialogue box for display
func display_text(text: String, voice: String):
	var dialogue_box = find_dialogue_box()
	if dialogue_box:
		dialogue_box.display_text(text, voice)
	else:
		print("DialogueBox not found in DialogueUI group!")

# Reset trigger count for specific dialogue
func reset_dialogue_state(dialogue_id: String):
	if dialogue_state.has(dialogue_id):
		dialogue_state[dialogue_id]["times_triggered"] = 0

# Reset trigger counts for all dialogues
func reset_all_dialogue_states():
	for dialogue_id in dialogue_state.keys():
		dialogue_state[dialogue_id]["times_triggered"] = 0
