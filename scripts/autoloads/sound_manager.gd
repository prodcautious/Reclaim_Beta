extends Node

@onready var music_player = AudioStreamPlayer.new()

var sfx_sounds = {}
var music_tracks = {}
var dialogue_sounds = {}

var fade_duration = 0.5
var fade_timer = Timer.new()
var sfx_players = []
var dialogue_players = []

const MAX_SFX_PLAYERS = 10

func _ready():
	add_child(music_player)
	add_child(fade_timer)

	music_player.bus = "Music"
	music_player.stream_paused = false
	music_player.process_mode = AudioStreamPlayer.PROCESS_MODE_ALWAYS

	# Initialize SFX Sound Bus
	sfx_sounds["damage_1"] = load("res://assets/audio/sfx/character/damage_1.ogg")
	sfx_sounds["heal"] = load("res://assets/audio/sfx/character/heal.ogg")
	sfx_sounds["click_1"] = load("res://assets/audio/sfx/ui/click_1.ogg")
	
	# Initialize Dialogue Sound Bus
	sfx_sounds["voice_1"] = load("res://assets/audio/sfx/voices/voice_1.wav")
	dialogue_sounds["voice_1"] = sfx_sounds["voice_1"]
	sfx_sounds["voice_2"] = load("res://assets/audio/sfx/voices/voice_2.wav")
	dialogue_sounds["voice_2"] = sfx_sounds["voice_2"]

	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

		var dialogue_player = AudioStreamPlayer.new()
		dialogue_player.bus = "Dialogue"
		add_child(dialogue_player)
		dialogue_players.append(dialogue_player)

	fade_timer.set_wait_time(fade_duration / 5)
	fade_timer.connect("timeout", Callable(self, "_on_fade_timer_timeout"))

func play_dialogue_sound(sound_name: String):
	if dialogue_sounds.has(sound_name):
		var dialogue_player = _get_free_dialogue_player()
		if dialogue_player:
			dialogue_player.stream = dialogue_sounds[sound_name]
			dialogue_player.play()

func play_sfx_sound(sound_name: String):
	if sfx_sounds.has(sound_name):
		var sfx_player = _get_free_sfx_player()
		if sfx_player:
			sfx_player.stream = sfx_sounds[sound_name]
			sfx_player.pitch_scale = randf_range(0.9, 1.1)
			sfx_player.play()

func _get_free_sfx_player() -> AudioStreamPlayer:
	for sfx_player in sfx_players:
		if not sfx_player.is_playing():
			return sfx_player
	return null

func _get_free_dialogue_player() -> AudioStreamPlayer:
	for dialogue_player in dialogue_players:
		if not dialogue_player.is_playing():
			return dialogue_player
	return null

func play_music(track_name: String):
	if music_tracks.has(track_name):
		music_player.stream = music_tracks[track_name]
		music_player.play()
		music_player.volume_db = 0

func stop_music():
	fade_timer.start()

func _on_fade_timer_timeout():
	music_player.volume_db -= 16
	if music_player.volume_db <= -80:
		music_player.stop()
		fade_timer.stop()
