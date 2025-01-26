extends Node
var playername: String = "JELLY"
var enemyvariants: PackedStringArray = ["tired", "casual", "happy", "smug", "anxious", "annyoyed", "furious", "nightmare"]
var enemies: Dictionary = {
	"blob": {
		"hp": [50.0, 50.0, 100.0, 150.0, 250.0, 500.0, 750.0, 1250.0],
		"atk": [3.0, 6.0, 14.0, 21.0, 27.0, 34.0, 45.0, 79.0],
		"def": [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0]
	},
	"wall": {
		"hp": [250.0, 500.0, 1000.0, 2500.0, 3500.0, 5000.0, 7500.0, 12500.0],
		"atk": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		"def": [30.0, 50.0, 75.0, 125.0, 175.0, 250.0, 350.0, 400.0]
	},
	"flarp": {
		"hp": [50.0, 50.0, 100.0, 150.0, 250.0, 500.0, 750.0, 1250.0],
		"atk": [3.0, 6.0, 14.0, 21.0, 27.0, 34.0, 45.0, 79.0],
		"def": [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0]
	}
}
var leveldata: Dictionary = {
	"name": "",
	"tiles": "",
	"rooms": [],
	"enemydata": enemies,
	"enemyplace": "",
	"playerspawn": Vector2i(),
	"teleporters": ""
}
var version: String = "0.1"
func _ready() -> void:
	DiscordRPC.app_id = 1302687543187210402
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.large_image = "icon"
	DiscordRPC.refresh()
func calcbattlevalues(pstats: Dictionary, estats: Dictionary) -> Dictionary:
	var turncount: int = ceil(estats.hp / (pstats.atk - estats.def))
	var damage: int = estats.atk * (turncount - 1) - pstats.def
	return {
		"turncount": turncount,
		"damage": damage
	}
func notify(text: String) -> void:
	if get_child_count():
		get_child(0).addlabel(text)
	else:
		var n: CanvasLayer = preload("res://scenes/notification.tscn").instantiate()
		add_child(n)
		n.addlabel(text)
func setupdialog(pages: PackedStringArray, events: String, talker: String) -> Sprite2D:
	var i: Sprite2D = preload("res://scenes/dialog.tscn").instantiate()
	i.pages = pages
	i.events = events
	i.talker = talker
	return i
