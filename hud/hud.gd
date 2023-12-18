extends CanvasLayer

@onready var loot_display = $loot_display

func _process(delta):
	loot_display.clear()
	loot_display.add_text("LOOT: ")
	loot_display.add_text(str(_Globals.player_loot))
