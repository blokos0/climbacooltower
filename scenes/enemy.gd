extends Sprite2D
var kind: String = "blob"
var variant: int
func _ready() -> void:
	texture = load("res://sprites/" + str(kind) + ".png")
	region_rect = Rect2i(variant * 32, 0, 32, 32)
