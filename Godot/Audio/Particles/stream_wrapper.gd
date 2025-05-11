class_name StreamWrapper

var variations: Array[AudioStream]
var enabled: bool
var time: float = 0.0
var time_scale: float
var stream_offset: float
var play_offset: float
var play_gap: float
var play_marker: float
var volume: float
var pitch_scale: float
var flags: String = ""

func _init(_variations: Array[AudioStream], _enabled: bool = true, _time_scale: float = 1.0, _time_scale_rand: float = 0.0,
	_stream_offset: float = 0.0, _stream_offset_rand: float = 0.0, _play_offset: float = 0.0,
	_play_offset_rand: float = 0.0, _play_gap: float = 0.0, _play_gap_rand: float = 0.0,
	_volume: float = 1.0, _volume_rand: float = 0.0, _pitch_scale: float = 1.0,
	_pitch_scale_rand: float = 0.0, _flags: String = ""):
	randomize()
	enabled = _enabled
	variations = _variations
	time_scale = _time_scale + randf() * _time_scale_rand
	stream_offset = _stream_offset + randf() * _stream_offset_rand
	play_offset = _play_offset + randf() * _play_offset_rand
	play_marker = 0.0
	play_gap = _play_gap + randf() * _play_gap_rand
	volume = _volume + randf() * _volume_rand
	pitch_scale = _pitch_scale + randf() * _pitch_scale_rand
	flags = _flags

func update(_time: float) -> AudioStream: # Use null check for should_play
	time = _time
	
	if !enabled or variations.is_empty(): return null
	
	var sound = null
	
	if time * time_scale > play_offset + play_marker:
		if variations.size() == 1:
			sound = variations[0]
		else:
			sound = variations[int(randf() * variations.size())]
		
		time = 0.0
		play_marker += sound.get_length() + play_gap
	
	return sound
	# return time * time_scale > play_offset + play_marker + play_gap

static func from_descriptor(_d: StreamDescriptor) -> StreamWrapper:
	return StreamWrapper.new(_d.variations, _d.enabled, _d.time_scale, _d.time_scale_rand, _d.stream_offset,
		_d.stream_offset_rand, _d.play_offset, _d.play_offset_rand, _d.play_gap, _d.play_gap_rand,
		_d.volume, _d.volume_rand, _d.pitch_scale, _d.pitch_scale_rand, _d.flags)

static func from_descriptors(_d: Array[StreamDescriptor]) -> Array[StreamWrapper]:
	var output: Array[StreamWrapper]
	var n = _d.size()
	output.resize(n)
	
	for i in n:
		output[i] = from_descriptor(_d[i])
	
	return output
