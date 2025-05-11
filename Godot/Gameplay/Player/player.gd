extends CharacterBody2D
class_name Player

const STOP_DISTANCE : float = 40.0       
const ROT_EASE : float = 6.0        

@export var _thrust : float = 300.0
@export var _turn_rate : float = 40.0

@onready var _grabber : Area2D = $Grabber
@onready var _grab_shape : CollisionShape2D  = $Grabber/CollisionShape2D

var _held : ParticleBasic = null
var _is_joy : bool = true
var _is_key : bool = false
func _physics_process(delta: float) -> void:
	
	if !_is_joy and !_is_key:
		# move toward mouse
		var to_mouse: Vector2 = get_global_mouse_position() - global_position
		var target_angle : float = to_mouse.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, ROT_EASE * delta * (1.0 - FluidManager.VISCOSITY))

		# calc thrust
		if to_mouse.length() > STOP_DISTANCE:
			var auto_accel := Vector2.UP.rotated(rotation) * lerpf(0.0, _thrust, clamp(to_mouse.length() / 100, 0.0, 1.0))
			velocity += auto_accel * (1.0 - FluidManager.VISCOSITY) * delta
	if _is_key:
		var thrust_input := Input.get_action_strength("Up") - Input.get_action_strength("Down")
		if thrust_input != 0.0:
			velocity += Vector2.UP.rotated(rotation) * _thrust * thrust_input * (1.0 - FluidManager.VISCOSITY) * delta
	
		# rotation
		var rot_input := Input.get_action_strength("Right") - Input.get_action_strength("Left")
		rotation += rot_input * _turn_rate * (1.0 - FluidManager.VISCOSITY) * delta
		
	if _is_joy: 
		var aim := Input.get_vector("Left","Right","Up","Down", 0.2)
		if aim.length() > 0.0:
			var target_angle := aim.angle() + PI/2
			rotation = lerp_angle(rotation, target_angle, _turn_rate * (1.0 - FluidManager.VISCOSITY) * delta)
			velocity += Vector2.UP.rotated(rotation) * _thrust * delta * (1.0 - FluidManager.VISCOSITY)
		
	# apply drag
	velocity -= velocity * FluidManager.VISCOSITY * FluidManager.DRAG_COEFF * delta
	if velocity.length_squared() < FluidManager.EPSILON:
		velocity = Vector2.ZERO

	_update_grabber()
	move_and_slide()

func _update_grabber() -> void:
	if Input.is_action_pressed("Action"):
		if _held == null:
			_held = _nearest_particle()
			if _held: _held.hold()
		else: _held.global_position = _grabber.global_position
	else:
		if _held:
			_held.release(velocity * 2.0)
			_held = null

func _nearest_particle() -> ParticleBasic:
	var best : ParticleBasic = null
	var best_d := INF

	for area in _grabber.get_overlapping_areas():
		var particle := area.get_parent() as ParticleBasic
		if particle:
			var dist := particle.global_position.distance_to(_grabber.global_position)
			if dist < best_d:
				best_d = dist
				best = particle
	return best
