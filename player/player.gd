extends CharacterBody2D

@export var speed := 100

var direction: Vector2
var can_loot := false
var current_loot: Node

func _physics_process(delta):
	handleMovement()
	move_and_slide()
	look_at(get_global_mouse_position())
	handleLooting()

func handleMovement():
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

func _on_interaction_range_body_entered(body):
	print("enter: ", body)
	if body.is_in_group("loot"):
		can_loot = true
		current_loot = body

func _on_interaction_range_body_exited(body):
	print("exit: ", body)
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
