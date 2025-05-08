extends CharacterBody2D
class_name Player

const EPSILON = 0.00001

@export var viscosity: float = 0.4    # 0 = water, 1 = sludge
@export var drag_coeff: float = 5.0

@export var thrust: float = 300.0     # thrust maximum to be assumed only possible at a viscosity of zero
@export var turn_rate: float = 4.0    

func _physics_process(delta: float) -> void:
	# forward thrust
	var thrust_input := Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	if thrust_input != 0.0:
		velocity += Vector2.UP.rotated(rotation) * thrust * thrust_input * (1.0 - viscosity) * delta
	
	# rotation
	var rot_input := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	rotation += rot_input * turn_rate * (1.0 - viscosity) * delta

	# apply drag
	velocity -= velocity * viscosity * drag_coeff * delta        
	if velocity.length_squared() < EPSILON:
		velocity = Vector2.ZERO

	move_and_slide()                              
