extends RigidBody2D

@export var pattern_size = 5
@export var tile_size = 32

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	makeRoom()


func makeRoom():
	collision_shape_2d.get_shape().size =\
	Vector2(pattern_size * tile_size, pattern_size * tile_size)
