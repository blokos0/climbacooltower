extends Node
var data: PackedStringArray
func _ready() -> void:
	play("res://cutscene/test.txt")
func play(path: String) -> void:
	data = FileAccess.get_file_as_string(path).split("\n")
	for e: String in data:
		if !e.is_empty():
			match e[0]:
				"@":
					var d: PackedStringArray = e.right(-1).split("|", true, 2)
					var i: Sprite2D = preload("res://scenes/dialog.tscn").instantiate()
					i.talker = d[0]
					i.events = d[1]
					i.pages = JSON.parse_string(d[2])
					add_child(i)
