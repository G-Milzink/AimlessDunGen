extends Node2D

@export var nr_of_rooms := 50
@export_range(0,99) var cull_percentage: int
@export_range(0,10) var horizontal_spread: int
@export_range(0,10) var vertical_spread: int

const TILE_SIZE = 32
const ROOM_A = preload("res://ADG/room_a.tscn")
const ROOM_B = preload("res://ADG/room_b.tscn")

var grid_origin := Vector2.ZERO
var room_a_positions: Array
var room_b_positions: Array
var used_cells: Array
var door_tiles: Array

@onready var tile_map = $TileMap

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _ready():
	randomize()
	makeRooms()
	await get_tree().create_timer(.5).timeout
	placePatterns()
	analyseLayout()

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
	await get_tree().create_timer(.25).timeout
	
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
	for pos in room_a_positions:
		tile_map.set_pattern(0,pos,$RoomPatterns.room_a_pattern)
	for pos in room_b_positions:
		tile_map.set_pattern(0,pos,$RoomPatterns.room_b_pattern)

func analyseLayout():
	#Analyse grid and sort tiles by functionality
	var tile_data: TileData
	used_cells = tile_map.get_used_cells(0)
	for cell in used_cells:
		tile_data = tile_map.get_cell_tile_data(0,cell)
		if tile_data.get_custom_data("is_door"):
			door_tiles.append(cell)
	
