extends CharacterBody2D

@export var walking_speed := 50
@export var aiming_speed := 10

@onready var flash_light = $FlashLight

var current_speed: int 

var direction: Vector2
var can_loot := false
var can_walk := true
var current_loot: Node

func _ready():
	flash_light.visible = false
	current_speed = walking_speed

func _physics_process(delta):
	handleAiming()
	handleMovement()
	move_and_slide()
	look_at(get_global_mouse_position())
	handleLooting()

func handleMovement():
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction && can_walk:
		velocity = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.y = move_toward(velocity.y, 0, current_speed)

func handleAiming():
	if Input.is_action_pressed("Aim"):
		flash_light.visible = true
		current_speed = aiming_speed
	else:
		flash_light.visible = false
		current_speed = walking_speed

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
