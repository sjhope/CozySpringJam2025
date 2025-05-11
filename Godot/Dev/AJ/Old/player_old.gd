extends CharacterBody2D
class_name PlayerOld

const EPSILON : float = 1e-5

@export var thrust: float = 300.0     # thrust maximum to be assumed only possible at a viscosity of zero
@export var turn_rate: float = 4.0    

@export var grab_force: float = 10.0
@onready var grabber: Area2D = $Grabber
@onready var grab_shape: CollisionShape2D  = $Grabber/CollisionShape2D

var _grabbed_particle: ParticleBasicOld = null
var _grab_radius: float

func _ready() -> void:
		_grab_radius = grab_shape.shape.radius * grab_shape.global_scale.x

func _physics_process(delta: float) -> void:
	# forward thrust
	var thrust_input := Input.get_action_strength("Up") - Input.get_action_strength("Down")
	if thrust_input != 0.0:
		velocity += Vector2.UP.rotated(rotation) * thrust * thrust_input * (1.0 - FluidManager.VISCOSITY) * delta
	
	# rotation
	var rot_input := Input.get_action_strength("Right") - Input.get_action_strength("Left")
	rotation += rot_input * turn_rate * (1.0 - FluidManager.VISCOSITY) * delta

	# apply drag
	velocity -= velocity * FluidManager.VISCOSITY * FluidManager.DRAG_COEFF * delta        
	if velocity.length_squared() < EPSILON:
		velocity = Vector2.ZERO

	# grabber
	if Input.is_action_pressed("Action"):
		if _grabbed_particle == null or !is_instance_valid(_grabbed_particle):
			
			# get closest particle to grabber center
			var nearest_dist : float = INF
			for area in grabber.get_overlapping_areas():
				var particle := area.get_parent() as ParticleBasicOld
				if particle:
					var distance := (particle.global_position - grabber.global_position).length()
					if distance < nearest_dist:
						nearest_dist = distance
						_grabbed_particle = particle
		
		# while holding keep particle snapped
		# TODO: need this to lerp into position, rather than perfectly snap
		if _grabbed_particle and is_instance_valid(_grabbed_particle):
			_grabbed_particle.global_position = grabber.global_position
			_grabbed_particle.velocity = Vector2.ZERO
	else:
		# "launch" a particle when let go
		if _grabbed_particle and is_instance_valid(_grabbed_particle):
			_grabbed_particle.velocity = velocity * 2
			_grabbed_particle = null    

	move_and_slide()               
