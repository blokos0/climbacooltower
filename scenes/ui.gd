extends CanvasLayer
func _ready() -> void:
	$container/box/playername.text = global.playername
func _process(_delta: float) -> void:
	$container/box/playerbox/playerportrait.texture.region.position.x = wrap(floor(float(Engine.get_process_frames()) / 20) * 100, 0, 300)
