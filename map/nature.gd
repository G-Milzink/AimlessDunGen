extends Node

@export var foliage_noise = FastNoiseLite
@export var water_noise = FastNoiseLite

func _ready():
	foliage_noise.seed = randi()
	water_noise.seed = randi()
