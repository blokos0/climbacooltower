@tool
extends Sprite2D
@export var kind: String = "blob":
	set(val):
		kind = val
		texture = load("res://sprites/" + str(kind) + ".png")
@export var variant: int:
	set(val):
		variant = val
		region_rect = Rect2i(variant * 32, 0, 32, 32)
