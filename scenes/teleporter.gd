extends Sprite2D
var pos: Vector2i
var room: String
var alt: bool
func _ready() -> void:
	texture = texture.duplicate() # sigh...
	texture.region.position.y = 32 * int(alt)
func _process(_delta: float) -> void:
	texture.region.position.x = wrap(floor(float(Engine.get_process_frames()) / 12.5) * 32, 0, 96)
