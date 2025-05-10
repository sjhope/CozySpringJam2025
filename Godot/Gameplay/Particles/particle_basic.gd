extends RigidBody2D
class_name ParticleBasic

enum ShapeType { CIRCLE, CAPSULE }

@export var _shape_type : ShapeType = ShapeType.CIRCLE
@export var _radius : float = 8.0
@export var _half_length : float = 16.0

var spring_joints : Array[PinJoint2D] = []

func _ready() -> void:
	setup_collider()
	ParticleManager.register_particle(self)
	linear_damp = FluidManager.VISCOSITY * FluidManager.DRAG_COEFF

func _exit_tree() -> void: 
	ParticleManager.unregister_particle(self)

func hold() -> void:
	freeze = true

func release(vel: Vector2) -> void:
	freeze = false
	linear_velocity = vel

func setup_collider() -> void:
	var col := get_node_or_null("CollisionShape2D")
	
	if col == null:
		col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		add_child(col)
		
		match _shape_type:
			ShapeType.CIRCLE:
				var shape := CircleShape2D.new()
				shape.radius = max(_radius, 1.0)
				col.shape = shape
				
			ShapeType.CAPSULE:
				var shape := CapsuleShape2D.new()
				shape.radius = max(_radius, 1.0)
				shape.height = max(_half_length, 0.0) * 2.0
				col.shape = shape
