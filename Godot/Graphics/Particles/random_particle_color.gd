extends MeshInstance2D

func _ready() -> void:
	#material.set_shader_parameter("color", [
	#	Color(0.0 / 255.0, 255.0 / 255.0, 83.0 / 255.0),
	#	Color(255.0 / 255.0, 8.0 / 255.0, 166.0 / 255.0),
	#	Color(8.0 / 255.0, 200.0 / 255.0, 255.0 / 255.0),
	#	Color(255.0 / 255.0, 239.0 / 255.0, 8.0 / 255.0)
	# 	].pick_random())
	material.set_shader_parameter("hue", [ 140.0, 322.0, 193.0, 56.0 ].pick_random())
	# material.set_shader_parameter("id", get_instance_id())
