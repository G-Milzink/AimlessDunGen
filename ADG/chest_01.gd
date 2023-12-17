extends Node2D

@onready var timer = $Timer
@onready var timer_display = $CanvasLayer/timer_display
@onready var canvas_layer = $CanvasLayer

@export var gold_min = 1
@export var gold_max = 5

var loot_amount: int
var has_been_looted = false

func ready():
	loot_amount = randi_range(gold_min,gold_max) * 5

func _process(delta):
	if !has_been_looted:
		if !timer.is_stopped():
			canvas_layer.visible = true
			timer_display.clear()
			timer_display.add_text(str(timer.time_left))
		else:
			canvas_layer.visible = false
