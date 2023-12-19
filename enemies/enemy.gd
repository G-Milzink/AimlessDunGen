extends CharacterBody2D

@export var walking_speed = 35
@export var hunting_duration = 30 #in seconds

@onready var nav_agent = $NavigationAgent2D
@onready var line_of_sight_ray = $LineOfSight
@onready var line_of_sight_timer = $LineOfSightTimer

const ACCEL = 5

var direction: Vector2
var current_speed: int

var player_in_visual_range = false
var hunting_player = false
var player_exists = false
var player: Node

func _ready():
	current_speed = walking_speed

func _physics_process(delta):
	if player == null:
		if get_tree().get_first_node_in_group("player"):
			player = get_tree().get_first_node_in_group("player")
			player_exists = true
		else:
			player_exists = false
	
	if player_exists:
		spotPlayer()
		huntPlayer(delta)
		look_at(player.position)
		
	move_and_slide()

func spotPlayer():
	if !hunting_player:
		if line_of_sight_ray.get_collider() == player:
			if !line_of_sight_timer.is_stopped():
				line_of_sight_timer.stop()
			hunting_player = true
	else:
		if line_of_sight_timer.is_stopped():
			line_of_sight_timer.start(hunting_duration)

func _on_line_of_sight_timer_timeout():
	hunting_player = false

func huntPlayer(delta):
	if hunting_player:
		nav_agent.target_position = get_tree().get_first_node_in_group("player").position
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * current_speed, ACCEL * delta)
	else:
		velocity = velocity.lerp(Vector2(0,0), ACCEL*delta)
