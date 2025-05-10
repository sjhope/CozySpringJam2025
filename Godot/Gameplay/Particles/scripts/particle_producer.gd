extends ParticleBasic
class_name ParticleProducer

@export var _energy_rate : float = 1.0
@export var _energy_value : float = 0.2
@onready var _timer : Timer = Timer.new()

func _ready() -> void:
	super._ready()
	add_child(_timer)
	_energy_rate = clampf(_energy_rate, 0.0, 1.0)
	_energy_value = clampf(_energy_value, 0.0, 1.0)
	_timer.start(_energy_rate)
	
func _process(delta: float) -> void:
	if _timer.is_stopped(): _timer.start(_energy_rate)
	
	for joint in spring_joints:
		var a = get_node(joint.node_a)
		var b = get_node(joint.node_b)
		
		if a != self and a is ParticleConsumer:
			a.add_energy(_energy_value)
		elif b != self and b is ParticleConsumer:
			b.add_energy(_energy_value)
