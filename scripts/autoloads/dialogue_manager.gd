extends Node

# Dictionary storing all dialogue data with structure:
# - window_1, door_1, etc: Dialogue event IDs
# - type: "sequential" (changes based on # of triggers) or "normal" (always same)
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
var dialogue_active = false  # Whether dialogue is currently being shown
var current_dialogue = []    # Current set of messages being displayed
var dialogue_index = 0       # Index of current message in dialogue sequence
var is_typing = false       # Whether text is currently being typed out
var dialogue_state = {}      # Tracks how many times sequential dialogues triggered

# Signals for event handling
signal dialogue_started
signal dialogue_finished
signal typing_finished

# Initialize dialogue state tracking for sequential dialogues
func _ready():
	for dialogue_id in dialogue_data.keys():
		if dialogue_data[dialogue_id]["type"] == "sequential":
			dialogue_state[dialogue_id] = {
				"times_triggered": 0
			}

# Start dialogue sequence if not active, or show next line if already active
func start_dialogue(dialogue_id: String):
	if not dialogue_active:
		if dialogue_data.has(dialogue_id):
			var dialogue = dialogue_data[dialogue_id]
			
			# Handle based on dialogue type
			if dialogue["type"] == "sequential":
				handle_sequential_dialogue(dialogue_id)
			else:
				handle_normal_dialogue(dialogue_id)
		else:
			print("Dialogue ID not found: " + dialogue_id)
	elif not is_typing:
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

# Display next line in current dialogue sequence
func show_next_line():
	if dialogue_index < current_dialogue.size():
		is_typing = true
		display_text(current_dialogue[dialogue_index].text, current_dialogue[dialogue_index].voice)
		dialogue_index += 1
	else:
		dialogue_active = false
		is_typing = false
		emit_signal("dialogue_finished")
		print("Dialogue finished.")

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
