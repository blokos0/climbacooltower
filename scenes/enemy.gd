@tool
extends Sprite2D
@export var id: String = "blob":
	set(val):
		id = val
		texture = load("res://sprites/" + str(id) + ".png")
@export var variant: int:
	set(val):
		variant = val
		region_rect = Rect2i(variant * 32, 0, 32, 32)
