extends RigidBody2D

@onready var collision_shape_2d = $CollisionShape2D

@export var room_size = 5
@export var tile_size = 32

func _ready():
	makeRoom()


func makeRoom():
	collision_shape_2d.get_shape().size =\
	Vector2(room_size * tile_size, room_size * tile_size)
