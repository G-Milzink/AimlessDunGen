extends StaticBody2D

@onready var timer = $Timer
@onready var timer_display = $Sprite2D/timer_display
@onready var sprite = $Sprite2D
@onready var shine = $PointLight2D

@export var loot_min = 1
@export var loot_max = 5
@export var shine_freq = 2.0
@export var shine_intensity = 0.35

var loot_amount : int
var has_been_looted = false
var time: float

#-------------------------------------------------------------------------------

func _process(delta):
	modulateEnergy(delta)
	handleBeingLooted()

#-------------------------------------------------------------------------------

func modulateEnergy(delta):
	time += delta
	shine.energy = ((sin(time * shine_freq)+1)*0.5) * shine_intensity

func handleBeingLooted():
	if !has_been_looted:
		shine.visible = true
		if !timer.is_stopped():
			timer_display.visible = true
			timer_display.clear()
			timer_display.add_text(str(timer.time_left))
		else:
			timer_display.visible = false
	else:
		shine.visible = false

func _on_timer_timeout():
	timer_display.visible = false
	has_been_looted = true
	sprite.set_frame(1)
	loot_amount = randi_range(loot_min,loot_max) * _Globals.loot_multiplier
	_Globals.player_loot = _Globals.player_loot + loot_amount


