extends StaticBody2D

@onready var timer = $Timer
@onready var timer_display = $Sprite2D/timer_display
@onready var sprite_2d = $Sprite2D


@export var gold_min = 1
@export var gold_max = 5

var loot_amount := 5
var has_been_looted = false

func ready():
	loot_amount =  5
	print("loot_amount?")

func _process(delta):
	if !has_been_looted:
		if !timer.is_stopped():
			timer_display.visible = true
			timer_display.clear()
			timer_display.add_text(str(timer.time_left))
		else:
			timer_display.visible = false

func _on_timer_timeout():
	timer_display.visible = false
	has_been_looted = true
	sprite_2d.set_frame(1)
	_Globals.player_loot = _Globals.player_loot + loot_amount
