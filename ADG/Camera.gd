extends Camera2D

var zoom_target  = Vector2(1.0,1.0)
func _ready():
	self.set_zoom(Vector2(0.1,0.1))

func _process(delta):
	if get_tree().get_first_node_in_group("player"):
		self.set_zoom(lerp(self.get_zoom(), zoom_target, 5*delta))
		position = get_tree().get_first_node_in_group("player").position

