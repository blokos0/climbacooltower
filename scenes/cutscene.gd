extends Node
var data: PackedStringArray
var pos: int
var wait: int
func _ready() -> void:
	play("test")
func _process(_delta: float) -> void:
	if pos >= len(data):
		queue_free()
		return
	if !get_child_count():
		wait = maxi(wait - 1, 0)
		if !wait:
			var e: String = data[pos]
			if !e.is_empty():
				match e[0]:
					"@":
						var d: PackedStringArray = e.right(-1).split("|", true, 2)
						var i: Sprite2D = preload("res://scenes/dialog.tscn").instantiate()
						i.talker = d[0]
						i.events = d[1]
						i.pages = JSON.parse_string(d[2])
						add_child(i)
					"#":
						match e[1]:
							"#":
								$"../music".stream_paused = true
							">":
								$"../music".stream_paused = false
							_:
								$"../music".stream = load("res://music/" + e.right(-1) + ".ogg")
								$"../music".play()
					"!":
						wait = int(e.right(-1))
			pos += 1
func play(namae: String) -> void:
	data = FileAccess.get_file_as_string("res://cutscene/" + namae + ".txt").split("\n")
