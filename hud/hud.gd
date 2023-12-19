extends CanvasLayer

@onready var loot_display = $loot_display
@onready var ammo_display = $ammo_display
@onready var clip_display = $clip_display

func _process(_delta):
	loot_display.clear()
	loot_display.add_text("LOOT: ")
	loot_display.add_text(str(_Globals.player_loot))
	
	ammo_display.clear()
	ammo_display.add_text("AMMO: ")
	ammo_display.add_text(str(_Globals.player_ammo))
	
	clip_display.clear()
	clip_display.add_text("CLIP: ")
	clip_display.add_text(str(_Globals.ammo_in_clip))
