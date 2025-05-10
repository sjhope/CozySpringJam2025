extends ParticleBasic
class_name ParticleConsumer

@export var _energy_factor : float = 0.07

var _energy : float = 1.0 # range 0.0 -> 1

func _process(delta: float) -> void:
	_energy -= clamp(_energy_factor * delta, 0.0, 1.0)
	_scale(lerp(_min_size, _max_size, _energy))
	if _energy < FluidManager.EPSILON:
		super.pop()
		
func add_energy(energy: float) -> void:
	_energy += energy
	_energy = clamp(_energy, 0.0, 1.0)

func _scale(new_scale: Vector2) -> void:
	cur_scale = new_scale
	_grab_col.scale = new_scale
	_sprite.scale = new_scale
	_col.scale = new_scale
