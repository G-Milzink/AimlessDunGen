extends Node2D

var energy_deviation: float


func _process(delta):
	energy_deviation = sin(Time.get_ticks_msec())*0.75
	self.energy = lerp(self.energy, 1-energy_deviation, 2.5*delta)
