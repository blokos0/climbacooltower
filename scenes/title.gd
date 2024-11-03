extends Node2D
func _process(_delta: float) -> void:
	$logo.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32) * 6, 130 + sin(float(Engine.get_process_frames()) / 16) * 3)
	$logotrail.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32 + 1) * 8, 130 + sin(float(Engine.get_process_frames()) / 16 + 1) * 5)
	$logotrail.modulate = Color.from_hsv(float(Engine.get_process_frames()) / 256, 1, 3, 0.5)
	$bg.region_rect = Rect2(float(Engine.get_process_frames()) / 4, 0, 640, 360)
