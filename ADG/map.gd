extends Node2D

#region Exported variables
@export var spawn_player := false
@export var nr_of_rooms := 50
@export_range(0,99) var cull_percentage: int
@export_range(0,10) var horizontal_spread: int
@export_range(0,10) var vertical_spread: int
@export var edge_buffer: int
#endregion

#region Constants
const TILE_SIZE = 32
const ROOM_A = preload("res://ADG/room_a.tscn")
const ROOM_B = preload("res://ADG/room_b.tscn")
#endregion

#region Function variables
var grid_origin := Vector2.ZERO
var room_a_positions: Array
var room_b_positions: Array

var used_cells: Array
var door_tiles: Array
var wall_tiles: Array

var astar_grid := AStarGrid2D.new()
var grid_edge_X := 0
var grid_edge_Y := 0
#endregion

@onready var tile_map = $TileMap

#-------------------------------------------------------------------------------

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _ready():
	#RenderingServer.set_default_clear_color(Color("080a12"))
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_GRAY)
	randomize()
	makeRooms()
	await get_tree().create_timer(1).timeout
	placePatterns()
	analyseLayout()
	generateHallways()

#-------------------------------------------------------------------------------

func makeRooms():
	var rng: int
	var room: Node2D
	var pos: Vector2
	var tile_map_coords: Vector2
	
	#Generate rooms:
	for i in nr_of_rooms:
		rng = randi() % 100
		if rng >= 50:
			room = ROOM_A.instantiate()
		else:
			room = ROOM_B.instantiate()
		pos.x = randi_range(-horizontal_spread,horizontal_spread)
		pos.y = randi_range(-vertical_spread,vertical_spread)
		room.position = pos
		$Rooms.add_child(room)
	
	# wait for rooms to settle:
	await get_tree().create_timer(0.5).timeout
	
	# cull rooms:
	for _room in $Rooms.get_children():
		if randi() % 100 <= cull_percentage:
			_room.queue_free()
		else:
			_room.set_freeze_enabled(true)
			if _room.position.x < grid_origin.x:
				grid_origin.x = _room.position.x
			if _room.position.y < grid_origin.y:
				grid_origin.y = _room.position.y
	
	#wait for end of frame:
	await Engine.get_main_loop().process_frame
	
	#move rooms to positive grid positions:
	for _room in $Rooms.get_children():
		_room.position = (_room.position - grid_origin) + Vector2(TILE_SIZE,TILE_SIZE)
		tile_map_coords = tile_map.local_to_map(_room.position)
		
		#sort rooms by type and store tile map coordinates:
		if _room.is_in_group("room_a"):
			room_a_positions.append(tile_map_coords)
		if _room.is_in_group("room_b"):
			room_b_positions.append(tile_map_coords)

func placePatterns():
	var rng: int
	var pattern: TileMapPattern
	for pos in room_a_positions:
		rng = randi() % 100
		if rng < 25 : pattern = $RoomPatterns.room_a_north
		elif rng < 50 : pattern = $RoomPatterns.room_a_east
		elif rng < 75 : pattern = $RoomPatterns.room_a_south
		else: pattern = $RoomPatterns.room_a_west
		tile_map.set_pattern(0,pos,pattern)
	for pos in room_b_positions:
		rng = randi() % 100
		if rng < 25 : pattern = $RoomPatterns.room_b_north
		elif rng < 50 : pattern = $RoomPatterns.room_b_east
		elif rng < 75 : pattern = $RoomPatterns.room_b_south
		else: pattern = $RoomPatterns.room_b_west
		tile_map.set_pattern(0,pos,pattern)

func analyseLayout():
	#Analyse grid:
	var tile_data: TileData
	used_cells = tile_map.get_used_cells(0)
	for cell in used_cells:
		# Determine grid edges:
		if cell.x > grid_edge_X:
			grid_edge_X = cell.x
		if cell.y > grid_edge_Y:
			grid_edge_Y = cell.y
		# Filter out tiles accoring to custom data:
		tile_data = tile_map.get_cell_tile_data(0,cell)
		if tile_data.get_custom_data("is_door"):
			door_tiles.append(cell)
		if tile_data.get_custom_data("is_wall"):
			wall_tiles.append(cell)

func generateHallways():
	# Setup astar grid:
	astar_grid.region = Rect2i(0, 0, grid_edge_X+edge_buffer, grid_edge_Y+edge_buffer)
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.set_diagonal_mode(AStarGrid2D.DIAGONAL_MODE_NEVER)
	astar_grid.set_default_compute_heuristic(1)
	astar_grid.set_default_estimate_heuristic(1)
	astar_grid.update()
	
	# Set wall tiles to solid:
	for tile in wall_tiles:
		astar_grid.set_point_solid(tile)
		
	#create paths:
	var path: = []
	for i in door_tiles.size():
		path = astar_grid.get_id_path(door_tiles[0],door_tiles[i])
		tile_map.set_cells_terrain_connect(0,path,0,0,false)



