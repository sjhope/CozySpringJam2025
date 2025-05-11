extends AudioStreamPlayer2D

@export var sounds: Array[StreamDescriptor] = []
var streams: Array[StreamWrapper] = []

func _ready() -> void:
	streams = StreamWrapper.from_descriptors(sounds)
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = sounds.size()
	play()

var time = 0.0

func _process(delta: float) -> void:
	var playback = get_stream_playback() as AudioStreamPlaybackPolyphonic
	#print(time)
	
	var shader_time = 0.0
	var n1 = streams.size()
	
	for i in n1:
		streams[i].time = time
		
		var sound = null
		var n2 = streams[i].variations.size()
		
		if streams[i].enabled and n2 != 0:
			if n2 == 1:
				sound = streams[i].variations[0]
			else:
				sound = streams[i].variations[int(randf() * n2)]
		
		if streams[i].time * streams[i].time_scale > streams[i].play_offset + streams[i].play_marker:
			streams[i].time = 0.0
			streams[i].play_marker += streams[i].play_gap
			
			if sound != null:
				streams[i].play_marker += sound.get_length()
				playback.play_stream(sound, streams[i].stream_offset, streams[i].volume,
					streams[i].pitch_scale)
		
		if streams[i].flags.contains("TIME"):
			shader_time += streams[i].time * streams[i].time_scale + streams[i].play_marker
	
	$"../ParticleMesh".material.set_shader_parameter("ext_time", shader_time)
	time += delta
