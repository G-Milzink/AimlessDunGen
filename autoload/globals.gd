extends Node

@export_category("debug settings:")
@export var spawn_player = true
@export var spawn_enemies = true
@export var disable_canvas_mod = false
@export_category("player parameters:")
@export var starting_damage = 30
@export var damage_rng = 5
@export var start_with_full_clip = true
@export var clip_size = 6
@export var starting_ammo = 0
@export var starting_loot = 0
@export_category("game parameters:")
@export var loot_multiplier = 5

var current_damage: int
var player_ammo: int
var ammo_in_clip: int
var player_loot: int

func _ready():
	if start_with_full_clip:
		ammo_in_clip = clip_size
	else:
		ammo_in_clip = 0
	player_ammo = starting_ammo
	player_loot = starting_loot
	current_damage = starting_damage
