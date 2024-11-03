extends AnimatedSprite2D
var roomid: int
var pos: Vector2i
var alt: bool
func _ready() -> void:
	if alt:
		animation = "alt"
	else:
		animation = "default"
