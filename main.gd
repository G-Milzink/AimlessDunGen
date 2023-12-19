extends Node2D


func _input(event):
	if event.is_action_pressed("reset"):
		_Globals.player_loot = 0
		_Globals.player_ammo = 10
		_Globals.ammo_in_clip = 6
		get_tree().reload_current_scene()
