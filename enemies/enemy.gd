extends CharacterBody2D

@export var hunt_for_player = false
@export var walking_speed = 35
@export var hunting_duration = 30 #in seconds

@onready var sprite = $Sprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var line_of_sight_ray = $LineOfSight
@onready var line_of_sight_timer = $LineOfSightTimer
@onready var hunting_timer = $HuntingTimer
@onready var hunting_delay_timer = $HuntingDelayTimer


const ACCEL = 5

var direction: Vector2
var current_speed: int

var player_in_visual_range = false
var following_player = false
var hunting_player = false
var player_exists = false
var player: Node

func _ready():
	current_speed = walking_speed
	if randi() % 100 >= 50:
		hunt_for_player = true
	else:
		hunt_for_player = false

func _physics_process(delta):
	checkForPlayer()
	if player_exists:
		spotPlayer()
		followPlayer(delta)
		huntForPlayer(delta)
		if hunting_player:
			look_at(nav_agent.get_next_path_position())
		else:
			look_at(player.position)
	move_and_slide()
	handleAnimation()

func checkForPlayer():
	if player == null:
		if get_tree().get_first_node_in_group("player"):
			player = get_tree().get_first_node_in_group("player")
			player_exists = true
		else:
			player_exists = false

func spotPlayer():
	if !following_player:
		if line_of_sight_ray.get_collider() == player:
			if !line_of_sight_timer.is_stopped():
				line_of_sight_timer.stop()
			following_player = true
	else:
		if line_of_sight_timer.is_stopped():
			line_of_sight_timer.start(hunting_duration)

func _on_line_of_sight_timer_timeout():
	following_player = false

func huntForPlayer(delta):
	if !following_player && hunt_for_player:
		if hunting_timer.is_stopped() && hunting_delay_timer.is_stopped():
			hunting_timer.start(randi_range(1,5))
			hunting_player = true
			if randi() % 100 >= 75:
				nav_agent.target_position = get_tree().get_first_node_in_group("player").position
			else:
				nav_agent.target_position = get_tree().get_first_node_in_group("map").floor_tiles.pick_random()*32
		elif !hunting_timer.is_stopped() && hunting_delay_timer.is_stopped():
			direction = nav_agent.get_next_path_position() - global_position
			direction = direction.normalized()
			velocity = velocity.lerp(direction * current_speed, ACCEL * delta)
		else:
			velocity = velocity.lerp(Vector2(0,0), ACCEL*delta)

func _on_hunting_timer_timeout():
	if hunting_delay_timer.is_stopped():
		hunting_delay_timer.start(randi_range(1,5))
		hunting_player = false

func followPlayer(delta):
	if following_player:
		nav_agent.target_position = get_tree().get_first_node_in_group("player").position
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * current_speed, ACCEL * delta)
	else:
		velocity = velocity.lerp(Vector2(0,0), ACCEL*delta)

func handleAnimation():
	if following_player:
		sprite.set_frame(1)
	else:
		sprite.set_frame(0)


