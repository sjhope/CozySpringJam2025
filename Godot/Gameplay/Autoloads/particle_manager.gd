extends Node

const LINK_RADIUS : float = 10        
const BREAK_DIST  : float = LINK_RADIUS * 5.0
const SOFTNESS    : float = 2.0       

var particles : Array[ParticleBasic] = []
var _rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	var n := particles.size()

	# create joints
	for i in range(n - 1):
		var a := particles[i]
		for j in range(i + 1, n):
			var b := particles[j]
			
			if a.global_position.distance_to(b.global_position) > LINK_RADIUS * a.cur_scale.length() : continue
			if _pair_has_joint(a, b): continue
			_make_pin(a, b)

	# remove old joints
	for particle in particles:
		for joint in particle.spring_joints.duplicate():
			if !is_instance_valid(joint):
				particle.spring_joints.erase(joint)
				continue
				
			var body_a := get_node_or_null(joint.node_a)
			var body_b := get_node_or_null(joint.node_b)
			if body_a == null or body_b == null:
				joint.queue_free()
				particle.spring_joints.erase(joint)
				continue
				
			if body_a.global_position.distance_to(body_b.global_position) > BREAK_DIST:
				joint.queue_free()
				particle.spring_joints.erase(joint)

func _pair_has_joint(a: ParticleBasic, b: ParticleBasic) -> bool:
	var path_b := b.get_path()
	for joint in a.spring_joints:
		if is_instance_valid(joint) and joint.node_b == path_b:
			return true
	return false

func _make_pin(a: ParticleBasic, b: ParticleBasic) -> void:
	var pin := PinJoint2D.new()
	pin.node_a = a.get_path()
	pin.node_b = b.get_path()
	pin.disable_collision = false 
	pin.softness = SOFTNESS
	a.add_child(pin)
	a.spring_joints.append(pin)
	b.spring_joints.append(pin)

func register_particle(particle: ParticleBasic) -> void:    
	particles.append(particle)
	particle.offset = _get_offset()

func unregister_particle(particle: ParticleBasic) -> void:
	for joint in particle.spring_joints:
		if is_instance_valid(joint): joint.queue_free()
	particles.erase(particle)

func _get_offset() -> float:
	return _rng.randf_range(0.0, 1.0)
