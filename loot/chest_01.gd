extends StaticBody2D

@onready var timer = $Timer
@onready var timer_display = $Sprite2D/timer_display
@onready var sprite_2d = $Sprite2D


@export var loot_min = 1
@export var loot_max = 5

var loot_amount : int
var has_been_looted = false

func _process(_delta):
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
	loot_amount = randi_range(loot_min,loot_max) * _Globals.currency_multiplier
	_Globals.player_loot = _Globals.player_loot + loot_amount
