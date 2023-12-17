extends Node2D

var energy_deviation: float

@onready var light = $PointLight2D

func _process(delta):
	energy_deviation = sin(Time.get_ticks_msec())*0.75
	light.energy = lerp(light.energy, 1-energy_deviation, 2.5*delta)
