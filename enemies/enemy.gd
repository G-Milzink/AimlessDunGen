extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D

@export var walking_speed = 35
const ACCEL = 5
var direction: Vector2

var current_speed: int

func _ready():
	current_speed = walking_speed

func _physics_process(delta):
	if get_tree().get_first_node_in_group("player"):
		nav_agent.target_position = get_tree().get_first_node_in_group("player").position
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * current_speed, ACCEL * delta)
		
	move_and_slide()
