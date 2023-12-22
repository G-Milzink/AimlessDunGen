extends Node2D

@export var room_START_size = Vector2(11,11)
@export var room_BOSS_size = Vector2(19,19)
@export var room_FINISH_size = Vector2(19,19)
@export var room_A_size = Vector2(7,7)
@export var room_B_size = Vector2(9,9)
@export var pattern_spacing := Vector2(2,2)

#region TileMapPatterns:
#Room_Start
var room_start_north: TileMapPattern
var room_start_east: TileMapPattern
var room_start_south: TileMapPattern
var room_start_west: TileMapPattern
#Room_Boss
var room_boss_north: TileMapPattern
var room_boss_east: TileMapPattern
var room_boss_south: TileMapPattern
var room_boss_west: TileMapPattern
#Room_Finish
var room_finish_north: TileMapPattern
var room_finish_east: TileMapPattern
var room_finish_south: TileMapPattern
var room_finish_west: TileMapPattern
#Room_A
var room_a_north: TileMapPattern
var room_a_east: TileMapPattern
var room_a_south: TileMapPattern
var room_a_west: TileMapPattern
#Room_B
var room_b_north: TileMapPattern
var room_b_east: TileMapPattern
var room_b_south: TileMapPattern
var room_b_west: TileMapPattern
#endregion

func _ready():
	room_A_size = room_A_size + pattern_spacing
	room_A_Patterns()
	room_B_size = room_B_size + pattern_spacing
	room_B_Patterns()
	room_START_size = room_START_size + pattern_spacing
	room_Start_Patterns()
	room_BOSS_size = room_BOSS_size + pattern_spacing
	room_Boss_Patterns()
	room_FINISH_size = room_FINISH_size + pattern_spacing
	room_Finish_Patterns()

#-------------------------------------------------------------------------------
#Essential Rooms:
func room_Start_Patterns():
	var room_start_tiles: Array
	# Room_Start north:
	for x in room_START_size.x:
		for y in room_START_size.y:
			room_start_tiles.append(Vector2i(x,y))
	room_start_north = $Room_Start.get_pattern(0,room_start_tiles)
	# Room_Start east:
	room_start_tiles.clear()
	for x in range(room_START_size.x,room_START_size.x * 2):
		for y in room_START_size.y:
			room_start_tiles.append(Vector2i(x,y))
	room_start_east = $Room_Start.get_pattern(0,room_start_tiles)
	# Room_Start south:
	room_start_tiles.clear()
	for x in range(room_START_size.x*2,room_START_size.x * 3):
		for y in room_START_size.y:
			room_start_tiles.append(Vector2i(x,y))
	room_start_south = $Room_Start.get_pattern(0,room_start_tiles)
	# Room_Start west:
	room_start_tiles.clear()
	for x in range(room_START_size.x*3,room_START_size.x * 4):
		for y in room_START_size.y:
			room_start_tiles.append(Vector2i(x,y))
	room_start_west = $Room_Start.get_pattern(0,room_start_tiles)

func room_Boss_Patterns():
	var room_boss_tiles: Array
	# Room_Bosst north:
	for x in room_BOSS_size.x:
		for y in room_BOSS_size.y:
			room_boss_tiles.append(Vector2i(x,y))
	room_boss_north = $Room_Boss.get_pattern(0,room_boss_tiles)
	# Room_Boss east:
	room_boss_tiles.clear()
	for x in range(room_BOSS_size.x,room_BOSS_size.x * 2):
		for y in room_BOSS_size.y:
			room_boss_tiles.append(Vector2i(x,y))
	room_boss_east = $Room_Boss.get_pattern(0,room_boss_tiles)
	# Room_Boss south:
	room_boss_tiles.clear()
	for x in range(room_BOSS_size.x*2,room_BOSS_size.x * 3):
		for y in room_BOSS_size.y:
			room_boss_tiles.append(Vector2i(x,y))
	room_boss_south = $Room_Boss.get_pattern(0,room_boss_tiles)
	# Room_Boss west:
	room_boss_tiles.clear()
	for x in range(room_BOSS_size.x*3,room_BOSS_size.x * 4):
		for y in room_BOSS_size.y:
			room_boss_tiles.append(Vector2i(x,y))
	room_boss_west = $Room_Boss.get_pattern(0,room_boss_tiles)

func room_Finish_Patterns():
	var room_finish_tiles: Array
	# Room_Bosst north:
	for x in room_FINISH_size.x:
		for y in room_FINISH_size.y:
			room_finish_tiles.append(Vector2i(x,y))
	room_finish_north = $Room_Finish.get_pattern(0,room_finish_tiles)
	# Room_Boss east:
	room_finish_tiles.clear()
	for x in range(room_FINISH_size.x,room_FINISH_size.x * 2):
		for y in room_FINISH_size.y:
			room_finish_tiles.append(Vector2i(x,y))
	room_finish_east = $Room_Finish.get_pattern(0,room_finish_tiles)
	# Room_Boss south:
	room_finish_tiles.clear()
	for x in range(room_FINISH_size.x*2,room_FINISH_size.x * 3):
		for y in room_FINISH_size.y:
			room_finish_tiles.append(Vector2i(x,y))
	room_finish_south = $Room_Finish.get_pattern(0,room_finish_tiles)
	# Room_Boss west:
	room_finish_tiles.clear()
	for x in range(room_FINISH_size.x*3,room_FINISH_size.x * 4):
		for y in room_FINISH_size.y:
			room_finish_tiles.append(Vector2i(x,y))
	room_finish_west = $Room_Finish.get_pattern(0,room_finish_tiles)

#-------------------------------------------------------------------------------
#Rng Rooms:
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
