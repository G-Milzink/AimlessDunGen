extends Node

@export var max_hit_points = 100
var current_hitpoints: int

func _ready():
	current_hitpoints = max_hit_points

func takeDamage(amount):
	current_hitpoints -= amount
	if current_hitpoints <= 0:
		get_parent().queue_free()
