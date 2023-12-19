extends Node2D

var energy_deviation: float

@onready var light = $PointLight2D

func _ready():
	if randi() % 100 >= 50:
		light.set_enabled(false)

func _process(delta):
	if light:
		energy_deviation = sin(Time.get_ticks_msec())*0.15
		light.energy = lerp(light.energy, 0.5-energy_deviation, 2.5*delta)

