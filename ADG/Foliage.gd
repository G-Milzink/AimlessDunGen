extends Node

@export var foliage_noise = FastNoiseLite

func _ready():
	foliage_noise.seed = randi()
