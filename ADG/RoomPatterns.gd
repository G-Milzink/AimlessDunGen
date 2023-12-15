extends Node2D

@export var room_A_size = Vector2(7,7)
@export var room_B_size = Vector2(9,9)

var room_a_pattern: TileMapPattern
var room_b_pattern: TileMapPattern

func _ready():
	room_A_Patterns()
	room_B_Patterns()

func room_A_Patterns():
	var room_a_tiles: Array
	for x in 7:
		for y in 7:
			room_a_tiles.append(Vector2i(x,y))
	room_a_pattern = $Room_A.get_pattern(0,room_a_tiles)

func room_B_Patterns():
	var room_b_tiles: Array
	for x in 9:
		for y in 9:
			room_b_tiles.append(Vector2i(x,y))
	room_b_pattern = $Room_B.get_pattern(0,room_b_tiles)
