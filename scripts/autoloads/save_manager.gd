extends Node

const SAVE_FILE_PATH = "user://save_game.json"

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		print("Game saved successfully")
	else:
		push_error("Failed to save game")

func load_game() -> Dictionary:
	# Only check once if file exists
	var has_save = FileAccess.file_exists(SAVE_FILE_PATH)
	if not has_save:
		# Only print once when actually trying to load
		print("No save file found")
		return {}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			return json.data
		else:
			push_error("Error parsing save file")
			return {}
	return {}

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("Save file deleted")
