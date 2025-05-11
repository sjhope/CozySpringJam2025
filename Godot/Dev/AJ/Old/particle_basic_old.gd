extends Node2D
class_name ParticleBasicOld

const EPSILON : float = 1e-5

@export var velocity: Vector2 = Vector2.ZERO
@export var radius: float  =  8.0

@export var link_radius: float  = 64.0      # how far attraction acts (radius * 8)?
@export var link_strength: float  = 500.0     # "spring" coeff

static var _all_particles: Array = []

func _enter_tree() -> void: _all_particles.append(self)
func _exit_tree() -> void: _all_particles.erase(self)

func _physics_process(delta: float) -> void:
	_handle_attractor(delta)
	
	velocity -= velocity * FluidManager.VISCOSITY * FluidManager.DRAG_COEFF * delta
	
	if velocity.length_squared() < EPSILON:
		velocity = Vector2.ZERO
	global_position += velocity * delta

func _handle_attractor(delta: float) -> void:
	for i in range(_all_particles.size()):
		var other = _all_particles[i]
		
		if other == self: continue
		if int(self.get_instance_id()) > int(other.get_instance_id()): continue  

		var offset  = other.global_position - global_position
		var dist = offset.length()
		if dist < EPSILON: continue

		var min_d = radius + other.radius

		# particle collision
		if dist < min_d:
			var push = offset.normalized() * (min_d - dist) * 0.5
			global_position -= push
			other.global_position += push

			var normal = offset.normalized()
			var rel_vel = velocity - other.velocity
			var impulse = normal * rel_vel.dot(normal) * 0.5
			velocity -= impulse
			other.velocity += impulse

		# spring force
		elif dist < link_radius:
			var falloff = 1.0 - dist / link_radius
			var force = offset.normalized() * link_strength * falloff * delta
			velocity += force 
			other.velocity -= force 
