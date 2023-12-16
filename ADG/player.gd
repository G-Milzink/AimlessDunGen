extends CharacterBody2D

@export var speed := 100

var direction: Vector2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down",0.25)
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()
