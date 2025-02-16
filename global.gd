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
	"enemyplace": [],
	"playerspawn": Vector2i(),
	"teleporters": "",
	"startingroom": ""
}
var version: String = "0.1"
var dialogspawned: bool
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
func setupdialog(pages: PackedStringArray, events: String, talker: String) -> Variant:
	if dialogspawned:
		return false
	dialogspawned = true
	var i: Sprite2D = preload("res://scenes/dialog.tscn").instantiate()
	i.pages = pages
	i.events = events
	i.talker = talker
	return i
func filetoleveldata(filename: String) -> bool:
	# converts a tower file to global.leveldata while doing the necessary conversions, returns true on success, false otherwise
	var file: PackedByteArray = FileAccess.get_file_as_bytes("user://" + filename + ".cact")
	if file == PackedByteArray():
		return false
	var rawld: Dictionary = JSON.parse_string(file.decompress_dynamic(100000000, FileAccess.COMPRESSION_GZIP).get_string_from_utf8())
	leveldata.merge(rawld, true)
	var arr: PackedStringArray = rawld["rooms"].split("/")
	var rconv: Array[Dictionary]
	if rawld["rooms"] != "":
		for r in arr:
			rconv.append({
				"name": r.get_slice(",", 0),
				"rect": Rect2i(int(r.get_slice(",", 1)), int(r.get_slice(",", 2)), int(r.get_slice(",", 3)), int(r.get_slice(",", 4))),
				"theme": r.get_slice(",", 5),
				"song": r.get_slice(",", 6)
			})
	leveldata["rooms"] = rconv
	arr = rawld["playerspawn"].split(",")
	leveldata["playerspawn"] = Vector2i(int(arr[0]), int(arr[1]))
	enemies.merge(leveldata["enemydata"], true)
	arr = rawld["enemyplace"].split("/")
	var epconv: Array[Array]
	if rawld["enemyplace"] != "" && rawld["enemyplace"] != "0,0,,0": # this will haunt me forever
		for i in arr:
			epconv.append([Vector2i(int(i.get_slice(",", 0)), int(i.get_slice(",", 1))), i.get_slice(",", 2), int(i.get_slice(",", 3))])
	leveldata["enemyplace"] = epconv
	arr = rawld["teleporters"].split("/")
	var tconv: Array[Array]
	if rawld["teleporters"] != "":
		for i in arr:
			tconv.append([Vector2i(int(i.get_slice(",", 0)), int(i.get_slice(",", 1))), Vector2i(int(i.get_slice(",", 2)), int(i.get_slice(",", 3))), i.get_slice(",", 4), bool(int(i.get_slice(",", 5)))])
	leveldata["teleporters"] = tconv
	return true
	# no teleporter support yet...
