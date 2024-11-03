extends CanvasLayer
var timer: float
func _ready() -> void:
	$panel.position.y = -$panel.size.y
func _process(_delta: float) -> void:
	timer += 1
	$panel.position.y = -$panel.size.y + min(timer / 10, 1) * $panel.size.y - max(timer - 125, 0) / 25 * $panel.size.y
	if timer == 150:
		queue_free()
func addlabel(text: String) -> void:
	timer = 10 * min($panel/box.get_child_count(), 1)
	var l: Label = Label.new()
	l.text = text
	$panel/box.add_child(l)
