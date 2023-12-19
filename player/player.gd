extends CharacterBody2D

@export var walking_speed := 50
@export var aiming_speed := 10

@onready var flash_light = $FlashLight
@onready var bullet_trajectory = $Line2D

const CURSOR_BASE = preload("res://0_PNG/cursors/cursor_base.png")
const CURSOR_AIM = preload("res://0_PNG/cursors/cursor_aim.png")

var current_speed: int 
var direction: Vector2
var can_loot := false
var can_walk := true
var current_loot: Node
var shooting = false
var aim_dev = Vector2.ZERO
var bullet_hit_location = Vector2.ZERO


func _ready():
	Input.set_custom_mouse_cursor(CURSOR_BASE)
	flash_light.visible = false
	bullet_trajectory.width = 1.0
	bullet_trajectory.default_color = Color(1.0,1.0,1.0,0.6)
	current_speed = walking_speed

func _draw():
	if shooting == true:
		bullet_trajectory.clear_points()
		bullet_trajectory.add_point(position)
		bullet_trajectory.add_point(bullet_hit_location)
		shooting = false
	else:
		bullet_trajectory.clear_points()

func _physics_process(_delta):
	handleAiming()
	handleMovement()
	handleLooting()
	move_and_slide()
	look_at(get_global_mouse_position())
	queue_redraw()

func handleMovement():
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction && can_walk:
		velocity = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.y = move_toward(velocity.y, 0, current_speed)

func handleAiming():
	if Input.is_action_pressed("aim"):
		Input.set_custom_mouse_cursor(CURSOR_AIM,Input.CURSOR_ARROW,Vector2(16,16))
		flash_light.visible = true
		current_speed = aiming_speed
		if Input.is_action_just_pressed("attack"):
			handleAttacking()
	else: 
		Input.set_custom_mouse_cursor(CURSOR_BASE,Input.CURSOR_ARROW,Vector2(16,16))
		flash_light.visible = false
		current_speed = walking_speed

func handleAttacking():
	if _Globals.ammo_in_clip > 0:
		var target = get_global_mouse_position()
		_Globals.ammo_in_clip -= 1
		aim_dev.x = randi_range(-10,10)
		aim_dev.y = randi_range(-10,10)
		print(aim_dev)
		shooting = true
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(position, target+aim_dev)
		var result = space_state.intersect_ray(query)
		if result:
			print(result.position)
			bullet_hit_location = result.position
		else:
			bullet_hit_location = target+aim_dev
	else:
		print("click...")

func _on_interaction_range_body_entered(body):
	if body.is_in_group("loot"):
		can_loot = true
		current_loot = body

func _on_interaction_range_body_exited(body):
	if body.is_in_group("loot"):
		can_loot = false
		current_loot = null

func handleLooting():
	if can_loot:
		if Input.is_action_just_pressed("action"):
			if !current_loot.has_been_looted:
				current_loot.get_child(2).start()
		if Input.is_action_just_released("action"):
			current_loot.get_child(2).stop()
