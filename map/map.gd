extends Node2D

#region Exported variables
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
const ROOM_START = preload("res://rooms/room_start.tscn")
const ROOM_BOSS = preload("res://rooms/room_boss.tscn")
const ROOM_FINISH = preload("res://rooms/room_finish.tscn")
#rng rooms:
const ROOM_A = preload("res://rooms/room_a.tscn")
const ROOM_B = preload("res://rooms/room_b.tscn")
#rng content:
const LIGHT = preload("res://lighting/light.tscn")
const LIGHT_RNG = preload("res://lighting/light_rng.tscn")
const CHEST_01 = preload("res://loot/Chest_01.tscn")
#tiles:
const FLOOR_TILE = Vector2(1,1)
const BLOCKED_FLOOR_TILE = Vector2(4,8)
#actors:
const PLAYER = preload("res://player/player.tscn")
const ENEMY_01 = preload("res://enemies/enemy_01.tscn")
#endregion

#region Function variables
var grid_origin := Vector2.ZERO

var room_start_position: Vector2
var player_spawn_position: Vector2
var room_boss_position: Vector2
var boss_spawn_position: Vector2
var room_finish_position: Vector2

var room_a_positions: Array
var room_b_positions: Array
var enemy_spawn_positions: Array

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
var loot_tiles: Array
var rng_loot_tiles: Array

var astar_grid := AStarGrid2D.new()
var grid_edge_X := 0
var grid_edge_Y := 0
#endregion

@onready var tile_map = $TileMap
@onready var canvas_mod = $Lighting/CanvasModulate
@onready var hud = $"../Hud"

#-------------------------------------------------------------------------------

func _ready():
	setup()
	makeRooms()
	await get_tree().create_timer(1).timeout
	disableRooms()
	placePatterns()
	#await get_tree().create_timer(1).timeout
	analyseLayout()
	generateHallways()
	fixMap_AddCollisions()
	updateFloorAndWallLocations()
	generateWater()
	generateFoliage()
	placeLights()
	await get_tree().create_timer(1).timeout
	captureInGameMap()
	placeLoot()
	spawnEnemies()
	spawnPlayer()

#-------------------------------------------------------------------------------

func setup():
	canvas_mod.visible = false
	tile_map.set_collision_animatable(true)
	RenderingServer.set_default_clear_color(Color.BLACK)
	#RenderingServer.set_default_clear_color(Color.DARK_SLATE_GRAY)
	randomize()

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
	room = ROOM_BOSS.instantiate()
	room.position = essential_room_pos.pop_front()
	$Rooms.add_child(room)
	room = ROOM_FINISH.instantiate()
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
			#_room.set_freeze_enabled(true)
			_room.get_child(0).set_deferred("disabled", true)
			if _room.position.x < grid_origin.x:
				grid_origin.x = _room.position.x
			if _room.position.y < grid_origin.y:
				grid_origin.y = _room.position.y
		else:
			_room.get_child(0).set_deferred("disabled", true)
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
		if _room.is_in_group("boss"):
			room_boss_position = tile_map_coords
		if _room.is_in_group("finish"):
			room_finish_position = tile_map_coords
		if _room.is_in_group("room_a"):
			room_a_positions.append(tile_map_coords)
		if _room.is_in_group("room_b"):
			room_b_positions.append(tile_map_coords)

func disableRooms():
	for room in $Rooms.get_children():
		room.get_child(0).set_deferred("disabled", true)
	$Rooms.queue_free()

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
	#Place START room:
	rng = randi() % 100
	if rng < 25 : pattern = $RoomPatterns.room_start_north
	elif rng < 50 : pattern = $RoomPatterns.room_start_east
	elif rng < 75 : pattern = $RoomPatterns.room_start_south
	else: pattern = $RoomPatterns.room_start_west
	tile_map.set_pattern(0,room_start_position,pattern)
	#Place BOSS room:
	rng = randi() % 100
	if rng < 25 : pattern = $RoomPatterns.room_boss_north
	elif rng < 50 : pattern = $RoomPatterns.room_boss_east
	elif rng < 75 : pattern = $RoomPatterns.room_boss_south
	else: pattern = $RoomPatterns.room_boss_west
	tile_map.set_pattern(0,room_boss_position,pattern)
	#Place FINISH room:
	rng = randi() % 100
	if rng < 25 : pattern = $RoomPatterns.room_finish_north
	elif rng < 50 : pattern = $RoomPatterns.room_finish_east
	elif rng < 75 : pattern = $RoomPatterns.room_finish_south
	else: pattern = $RoomPatterns.room_finish_west
	tile_map.set_pattern(0,room_finish_position,pattern)

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
		if tile_data.get_custom_data("is_boss_spawn"):
			tile_map.set_cell(0,cell,0,FLOOR_TILE)
			boss_spawn_position = tile_map.map_to_local(cell)
		if tile_data.get_custom_data("has_enemy"):
			tile_map.set_cell(0,cell,0,FLOOR_TILE)
			enemy_spawn_positions.append(cell)
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
		if tile_data.get_custom_data("has_loot"):
			loot_tiles.append(cell)
			tile_map.set_cell(0,cell,0,FLOOR_TILE)
		if tile_data.get_custom_data("can_have_loot"):
			rng_loot_tiles.append(cell)
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
	door_tiles.shuffle()
	for i in door_tiles.size():
		if not i+2 > door_tiles.size():
			path = astar_grid.get_id_path(door_tiles[i],door_tiles[i+1])
			tile_map.set_cells_terrain_path(0,path,0,0,false)
	door_tiles.shuffle()
	for i in door_tiles.size():
		if not i+2 > door_tiles.size():
			path = astar_grid.get_id_path(door_tiles[i],door_tiles[i+1])
			tile_map.set_cells_terrain_path(0,path,0,0,false)

func updateFloorAndWallLocations():
	#clear arrays:
	floor_tiles.clear()
	wall_tiles.clear()
	var tile_data: TileData
	for cell in tile_map.get_used_cells(0):
		tile_data = tile_map.get_cell_tile_data(0,cell)
		if tile_data.get_custom_data("is_wall"):
			wall_tiles.append(cell)
		if tile_data.get_custom_data("is_floor"):
			floor_tiles.append(cell)

func captureInGameMap():
	var rect = tile_map.get_used_rect()
	print(rect.size * 32)
	var vpt = get_viewport()
	vpt.position.x = -rect.size.x * 0.5
	vpt.position.x = -rect.size.y * 0.5
	var tex = vpt.get_texture()
	var img = tex.get_image()
	img.save_png("res://runtime_storage/map.png")
	if _Globals.disable_canvas_mod:
		canvas_mod.visible = false
	else:
		canvas_mod.visible = true

func generateWater():
	var noise_value : float
	var tile_data : TileData
	
	if generate_water:
		for tile in floor_tiles:
			noise_value = $Nature.water_noise.get_noise_2d(tile.x,tile.y)
			if noise_value > 0.1:
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
			if noise_value > 0.75:
				tile_map.set_cells_terrain_connect(2,[tile],0,2,false)
		for cell in tile_map.get_used_cells(0):
			tile_data = tile_map.get_cell_tile_data(0,cell)
			if tile_data.get_custom_data("is_wall"):
				tile_map.erase_cell(2,cell)

func placeLights():
	var light_instance: Node 
	for tile in  light_tiles:
		light_instance = LIGHT.instantiate()
		light_instance.position = tile_map.map_to_local(tile)
		$Lighting.add_child(light_instance)
	for tile in  rng_light_tiles:
		light_instance = LIGHT_RNG.instantiate()
		light_instance.position = tile_map.map_to_local(tile)
		$Lighting.add_child(light_instance)

func placeLoot():
	var loot_instance: Node 
	
	for loot_tile in  loot_tiles:
		loot_instance = CHEST_01.instantiate()
		loot_instance.position = tile_map.map_to_local(loot_tile)
		$Loot.add_child(loot_instance)
		
	for rng_loot_tile in  rng_loot_tiles:
		if randi() % 100 >= 50:
			loot_instance = CHEST_01.instantiate()
			loot_instance.position = tile_map.map_to_local(rng_loot_tile)
			$Loot.add_child(loot_instance)

func spawnEnemies():
	if _Globals.spawn_enemies:
		var enemy_instance: Node
		for pos in enemy_spawn_positions:
			enemy_instance = ENEMY_01.instantiate()
			enemy_instance.position = tile_map.map_to_local(pos)
			$Enemies.add_child(enemy_instance)

func spawnPlayer():
	if _Globals.spawn_player:
		var player = PLAYER.instantiate()
		player.position = player_spawn_position
		add_child(player)
		hud.visible = true

func fixMap_AddCollisions():
	var uc = tile_map.get_used_cells(0)
	for c in uc:
		var td = tile_map.get_cell_tile_data(0,c)
		#"re-set" floor tiles to ensure the entire floor is surrounded by walls.
		if td.get_custom_data("is_floor"):
			tile_map.set_cells_terrain_connect(0,[c],0,0,false)
		#set collision tiles on seperate layer overlapping wall tiles.
		if td.get_custom_data("is_wall"):
			tile_map.set_cell(3,c,3,Vector2(0,0))
