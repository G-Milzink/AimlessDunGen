extends Node2D

#region Exported variables
@export var spawn_player := false
@export var generate_water := true
@export var generate_foliage := true
@export var nr_of_rooms := 50
@export_range(0,99) var cull_percentage: int
@export_range(0,10) var horizontal_spread: int
@export_range(0,10) var vertical_spread: int
@export var edge_buffer: int
#endregion

#region Constants
const TILE_SIZE = 32
# essential rooms:
const ROOM_START = preload("res://ADG/room_start.tscn")
const PLAYER = preload("res://ADG/player.tscn")
#rng rooms:
const ROOM_A = preload("res://ADG/room_a.tscn")
const ROOM_B = preload("res://ADG/room_b.tscn")
#rng content:
const LIGHT = preload("res://ADG/light.tscn")
const LIGHT_RNG = preload("res://ADG/light_rng.tscn")
#tiles:
const FLOOR_TILE = Vector2(1,1)
const BLOCKED_FLOOR_TILE = Vector2(4,8)
#endregion

#region Function variables
var grid_origin := Vector2.ZERO

var room_start_position: Vector2
var player_spawn_position: Vector2

var room_a_positions: Array
var room_b_positions: Array

var essential_room_pos = [
	Vector2(0,50),
	Vector2(50,0),
	Vector2(-50,-50),
	Vector2(-50,50),
	Vector2(50,-50),
	Vector2(50,50)]

var used_cells: Array
var door_tiles: Array
var wall_tiles: Array
var floor_tiles: Array
var light_tiles: Array
var rng_light_tiles: Array

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
	RenderingServer.set_default_clear_color(Color.BLACK)
	#RenderingServer.set_default_clear_color(Color.DARK_SLATE_GRAY)
	randomize()
	makeRooms()
	await get_tree().create_timer(1).timeout
	placePatterns()
	await get_tree().create_timer(1).timeout
	analyseLayout()
	generateHallways()
	generateWater()
	generateFoliage()
	placeLights()
	placeRNG_Lights()
	spawnPlayer()

#-------------------------------------------------------------------------------

func makeRooms():
	var rng: int
	var room: Node2D
	var pos: Vector2
	var tile_map_coords: Vector2
	
	#Spawn Essential rooms:
	essential_room_pos.shuffle()
	room = ROOM_START.instantiate()
	room.position = essential_room_pos.pop_front()
	$Rooms.add_child(room)
	#Generate rng rooms:
	for i in nr_of_rooms:
		rng = randi() % 100
		pos.x = randi_range(-horizontal_spread,horizontal_spread)
		pos.y = randi_range(-vertical_spread,vertical_spread)
		if rng >= 50:
			room = ROOM_A.instantiate()
			room.position = pos
		else:
			room = ROOM_B.instantiate()
		room.position = pos
		$Rooms.add_child(room)
	
	# wait for rooms to settle:
	await get_tree().create_timer(0.5).timeout
	
	# cull rooms:
	for _room in $Rooms.get_children():
		if _room.is_in_group("essential")\
		or randi() % 100 >= cull_percentage:
			_room.set_freeze_enabled(true)
			if _room.position.x < grid_origin.x:
				grid_origin.x = _room.position.x
			if _room.position.y < grid_origin.y:
				grid_origin.y = _room.position.y
		else:
			_room.queue_free()
	
	#wait for end of frame:
	await Engine.get_main_loop().process_frame
	
	#move rooms to positive grid positions:
	for _room in $Rooms.get_children():
		_room.position = (_room.position - grid_origin) + Vector2(TILE_SIZE*5,TILE_SIZE*5)
		tile_map_coords = tile_map.local_to_map(_room.position)
		#sort rooms by type and store tile map coordinates:
		if _room.is_in_group("start"):
			room_start_position = tile_map_coords
		if _room.is_in_group("room_a"):
			room_a_positions.append(tile_map_coords)
		if _room.is_in_group("room_b"):
			room_b_positions.append(tile_map_coords)

func placePatterns():
	var rng: int
	var pattern: TileMapPattern
	
	#Place rng rooms: 
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
	#Place start room:
	rng = randi() % 100
	if rng < 25 : pattern = $RoomPatterns.room_start_north
	elif rng < 50 : pattern = $RoomPatterns.room_start_east
	elif rng < 75 : pattern = $RoomPatterns.room_start_south
	else: pattern = $RoomPatterns.room_start_west
	tile_map.set_pattern(0,room_start_position,pattern)

func analyseLayout():
	var tile_data: TileData
	
	#Analyse grid:
	used_cells = tile_map.get_used_cells(0)
	for cell in used_cells:
		# Determine grid edges:
		if cell.x > grid_edge_X:
			grid_edge_X = cell.x
		if cell.y > grid_edge_Y:
			grid_edge_Y = cell.y
		
		# Filter out tiles accoring to custom data:
		tile_data = tile_map.get_cell_tile_data(0,cell)
		if tile_data.get_custom_data("is_player_spawn"):
			tile_map.set_cell(0,cell,0,FLOOR_TILE)
			player_spawn_position = tile_map.map_to_local(cell)
		if tile_data.get_custom_data("is_door"):
			door_tiles.append(cell)
		if tile_data.get_custom_data("is_wall"):
			wall_tiles.append(cell)
		if tile_data.get_custom_data("is_floor"):
			floor_tiles.append(cell)
		if tile_data.get_custom_data("has_light"):
			light_tiles.append(cell)
			tile_map.set_cell(0,cell,0,FLOOR_TILE)
		if tile_data.get_custom_data("has_rng_light"):
			rng_light_tiles.append(cell)
			tile_map.set_cell(0,cell,0,FLOOR_TILE)

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
	var path := []
	door_tiles.sort()
	for i in door_tiles.size():
		if not i+2 > door_tiles.size():
			path = astar_grid.get_id_path(door_tiles[i],door_tiles[i+1])
			tile_map.set_cells_terrain_path(0,path,0,0,false)

func generateWater():
	var noise_value : float
	var tile_data : TileData
	
	if generate_water:
		for tile in floor_tiles:
			noise_value = $Nature.water_noise.get_noise_2d(tile.x,tile.y)
			if noise_value > 0.05:
				tile_map.set_cells_terrain_connect(1,[tile],0,1,false)
		for cell in tile_map.get_used_cells(0):
			tile_data = tile_map.get_cell_tile_data(0,cell)
			if tile_data.get_custom_data("is_wall"):
				tile_map.erase_cell(1,cell)

func generateFoliage():
	var noise_value : float
	var tile_data : TileData
	
	if generate_foliage:
		for tile in floor_tiles:
			noise_value = $Nature.foliage_noise.get_noise_2d(tile.x,tile.y)
			if noise_value > 0.05:
				tile_map.set_cells_terrain_connect(2,[tile],0,2,false)
		for cell in tile_map.get_used_cells(0):
			tile_data = tile_map.get_cell_tile_data(0,cell)
			if tile_data.get_custom_data("is_wall"):
				tile_map.erase_cell(2,cell)

func placeLights():
	var light_instance: Node 
	for tile in  light_tiles:
		light_instance = LIGHT.instantiate()
		light_instance.position = tile_map.map_to_local(tile)-Vector2(2,0)
		$Lighting.add_child(light_instance)

func placeRNG_Lights():
	var light_instance: Node 
	for tile in  rng_light_tiles:
		light_instance = LIGHT_RNG.instantiate()
		light_instance.position = tile_map.map_to_local(tile)-Vector2(2,0)
		$Lighting.add_child(light_instance)

func spawnPlayer():
	if spawn_player:
		var player = PLAYER.instantiate()
		player.position = player_spawn_position
		add_child(player)
