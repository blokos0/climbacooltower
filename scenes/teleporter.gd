@tool
extends AnimatedSprite2D
@export var roomid: int
@export var pos: Vector2i
@export var alt: bool
func _process(_delta: float) -> void:
	if alt:
		animation = "alt"
	else:
		animation = "default"
	if Engine.is_editor_hint():
		queue_redraw()
func _draw() -> void:
	if Engine.is_editor_hint():
		var telepos: Vector2 = to_local(($"..".rooms[roomid].pos + pos) * 32)
		var col: Color = Color.from_hsv(roomid * 0.027, 0.5, 1)
		draw_line(Vector2(16, 16), telepos + Vector2(16, 16), col, 4)
		draw_rect(Rect2(telepos, Vector2(32, 32)), col)
		draw_rect(Rect2(telepos, Vector2(32, 32)), Color.BLACK, false, 2)
