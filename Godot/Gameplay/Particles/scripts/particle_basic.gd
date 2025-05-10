extends RigidBody2D
class_name ParticleBasic

enum ShapeType { CIRCLE, CAPSULE }

@export var _shape_type : ShapeType = ShapeType.CIRCLE
@export var _radius : float = 8.0
@export var _half_length : float = 16.0
@export var _min_size : Vector2 = Vector2(0.6, 0.6)
@export var _max_size : Vector2 = Vector2(2.0, 2.0)

var spring_joints : Array[PinJoint2D] = []
var offset : float = 0.0
var _col : CollisionShape2D = null
var cur_scale : Vector2 = Vector2.ONE

@onready var _grab_col : Area2D = $Area2D
@onready var _sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	setup_collider()
	ParticleManager.register_particle(self)
	linear_damp = FluidManager.VISCOSITY * FluidManager.DRAG_COEFF

func _exit_tree() -> void: 
	ParticleManager.unregister_particle(self)

func pop() -> void:
	queue_free()

func hold() -> void:
	freeze = true

func release(vel: Vector2) -> void:
	freeze = false
	linear_velocity = vel

func setup_collider() -> void:
	_col = get_node_or_null("CollisionShape2D")
	
	if _col == null:
		_col = CollisionShape2D.new()
		_col.name = "CollisionShape2D"
		add_child(_col)
		
		match _shape_type:
			ShapeType.CIRCLE:
				var shape := CircleShape2D.new()
				shape.radius = max(_radius, 1.0)
				_col.shape = shape
				
			ShapeType.CAPSULE:
				var shape := CapsuleShape2D.new()
				shape.radius = max(_radius, 1.0)
				shape.height = max(_half_length, 0.0) * 2.0
				_col.shape = shape
