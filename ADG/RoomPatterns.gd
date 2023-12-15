extends Node2D

@export var room_A_size = Vector2(7,7)
@export var room_B_size = Vector2(9,9)

var room_a_north: TileMapPattern
var room_a_east: TileMapPattern
var room_a_south: TileMapPattern
var room_a_west: TileMapPattern
var room_b_north: TileMapPattern
var room_b_east: TileMapPattern
var room_b_south: TileMapPattern
var room_b_west: TileMapPattern

func _ready():
	room_A_Patterns()
	room_B_Patterns()

func room_A_Patterns():
	var room_a_tiles: Array
	# Room_A north:
	for x in room_A_size.x:
		for y in room_A_size.y:
			room_a_tiles.append(Vector2i(x,y))
	room_a_north = $Room_A.get_pattern(0,room_a_tiles)
	# Room_A east:
	room_a_tiles.clear()
	for x in range(room_A_size.x,room_A_size.x * 2):
		for y in room_A_size.y:
			room_a_tiles.append(Vector2i(x,y))
	room_a_east = $Room_A.get_pattern(0,room_a_tiles)
	# Room_A south:
	room_a_tiles.clear()
	for x in range(room_A_size.x*2,room_A_size.x * 3):
		for y in room_A_size.y:
			room_a_tiles.append(Vector2i(x,y))
	room_a_south = $Room_A.get_pattern(0,room_a_tiles)
	# Room_A west:
	room_a_tiles.clear()
	for x in range(room_A_size.x*3,room_A_size.x * 4):
		for y in room_A_size.y:
			room_a_tiles.append(Vector2i(x,y))
	room_a_west = $Room_A.get_pattern(0,room_a_tiles)


func room_B_Patterns():
	var room_b_tiles: Array
	# Room_B north:
	for x in room_B_size.x:
		for y in room_B_size.y:
			room_b_tiles.append(Vector2i(x,y))
	room_b_north = $Room_B.get_pattern(0,room_b_tiles)
	# Room_B east:
	room_b_tiles.clear()
	for x in range(room_B_size.x,room_B_size.x * 2):
		for y in room_B_size.y:
			room_b_tiles.append(Vector2i(x,y))
	room_b_east = $Room_B.get_pattern(0,room_b_tiles)
	# Room_B south:
	room_b_tiles.clear()
	for x in range(room_B_size.x*2,room_B_size.x * 3):
		for y in room_B_size.y:
			room_b_tiles.append(Vector2i(x,y))
	room_b_south = $Room_B.get_pattern(0,room_b_tiles)
	# Room_B west:
	room_b_tiles.clear()
	for x in range(room_B_size.x*3,room_B_size.x * 4):
		for y in room_B_size.y:
			room_b_tiles.append(Vector2i(x,y))
	room_b_west = $Room_B.get_pattern(0,room_b_tiles)
