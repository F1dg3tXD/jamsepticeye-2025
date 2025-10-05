extends Node3D
class_name Speaker

@onready var player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func play_sound(sound: AudioStream, bus_name: String = "Voices") -> void:
	if not sound:
		return
	if player.playing:
		player.stop()
	player.bus = bus_name
	player.stream = sound
	player.play()
