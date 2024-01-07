extends StaticBody2D

@onready var timer = $Timer
@onready var progress_bar = $Sprite2D/ProgressBar

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
			progress_bar.visible = true
			progress_bar.value = 1.-(timer.time_left/2.)
		else:
			progress_bar.visible = false
	else:
		shine.visible = false

func _on_timer_timeout():
	progress_bar.visible = false
	has_been_looted = true
	sprite.set_frame(1)
	loot_amount = randi_range(loot_min,loot_max) * _Globals.loot_multiplier
	_Globals.player_loot = _Globals.player_loot + loot_amount


