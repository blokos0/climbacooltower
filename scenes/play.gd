extends Node2D
var room: int = 0:
	set(val):
		room = val
		setuproom()
var stats: Dictionary = {
	"hp": 500.0,
	"atk": 25.0,
	"def": 0.0,
	"lvl": 1
}
var theme: String = ""
var song: String = ""
func _ready() -> void:
	var file: PackedByteArray = FileAccess.get_file_as_bytes("user://lets try that again #2.cact")
	var rawld: Dictionary = JSON.parse_string(file.decompress_dynamic(100000000, FileAccess.COMPRESSION_GZIP).get_string_from_utf8())
	global.leveldata.merge(rawld, true)
	var arr: PackedStringArray = rawld["rooms"].split("/")
	var rconv: Array[Dictionary]
	for r in arr:
		rconv.append({
			"name": r.get_slice(",", 0),
			"rect": Rect2i(int(r.get_slice(",", 1)), int(r.get_slice(",", 2)), int(r.get_slice(",", 3)), int(r.get_slice(",", 4))),
			"theme": r.get_slice(",", 5),
			"song": r.get_slice(",", 6)
		})
	global.leveldata["rooms"] = rconv
	arr = rawld["playerspawn"].split(",")
	global.leveldata["playerspawn"] = Vector2i(int(arr[0]), int(arr[1]))
	arr = global.leveldata["tiles"].split("/")
	for i in arr:
		var ind: int = int(i.get_slice(",", 0))
		var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
		var tm: TileMapLayer = $gamelayer/gameworldcontainer/gameworld/shader/floors
		if int(i.get_slice(",", 3)):
			tm = $gamelayer/gameworldcontainer/gameworld/shader/walls
		tm.set_cell(pos, 0, Vector2i(ind, int(i.get_slice(",", 3))))
	$gamelayer/gameworldcontainer/gameworld/shader/player.position = global.leveldata["playerspawn"] * 32
	global.enemies = global.leveldata["enemydata"]
	for i in global.leveldata["enemyplace"]:
		var e: Sprite2D = preload("res://scenes/enemy.tscn").instantiate()
		e.position = str_to_var("Vector2i" + i[0]) * 32
		e.kind = i[1]
		e.variant = i[2]
		$gamelayer/gameworldcontainer/gameworld/shader.add_child(e)
	if global.leveldata["teleporters"] != "":
		arr = global.leveldata["teleporters"].split("/")
		for i in arr:
			var t: AnimatedSprite2D = preload("res://scenes/teleporter.tscn").instantiate()
			t.position = Vector2i(int(i.get_slice(",", 0)), int(i.get_slice(",", 1))) * 32
			t.pos = Vector2i(int(i.get_slice(",", 2)), int(i.get_slice(",", 3)))
			t.roomid = int(i.get_slice(",", 4))
			t.alt = bool(int(i.get_slice(",", 5)))
			$gamelayer/gameworldcontainer/gameworld/shader.add_child(t)
	$gamelayer/gameworldcontainer/gameworld/shader.move_child($gamelayer/gameworldcontainer/gameworld/shader/player, $gamelayer/gameworldcontainer/gameworld/shader.get_child_count())
	DiscordRPC.state = "playing " + global.leveldata["name"]
	DiscordRPC.details = "placeholder"
	DiscordRPC.refresh()
	setuproom()
	updatestats()
func _process(_delta: float) -> void:
	$gamelayer/gameworldcontainer/gameworld/shader/camera.position = $gamelayer/gameworldcontainer/gameworld/shader/player.position + $gamelayer/gameworldcontainer/gameworld/shader/player.offset
func setuproom() -> void:
	if !global.leveldata["rooms"].is_empty():
		$ui/container/box/roomname.text = global.leveldata["rooms"][room].name
		$gamelayer/gameworldcontainer/gameworld/shader/camera.position = global.leveldata["rooms"][room].rect.position * 32 + Vector2i(316, 176)
	if theme != global.leveldata["rooms"][room].theme:
		$bg.free()
		theme = global.leveldata["rooms"][room].theme
		var bg: CanvasLayer = load("res://scenes/bg" + theme + ".tscn").instantiate()
		add_child(bg)
		move_child(bg, 2)
		if theme == "snowy":
			$gamelayer/gameworldcontainer/gameworld/shader.material = ShaderMaterial.new()
			$gamelayer/gameworldcontainer/gameworld/shader.material.shader = preload("res://shaders/glitch.gdshader")
		else:
			$gamelayer/gameworldcontainer/gameworld/shader.material = null
	if song != global.leveldata["rooms"][room].song:
		song = global.leveldata["rooms"][room].song
		$music.stream = load("res://music/" + global.leveldata["rooms"][room].song + ".ogg")
		$music.play()
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_left = global.leveldata["rooms"][room].rect.position.x
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_top = global.leveldata["rooms"][room].rect.position.y
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_right = global.leveldata["rooms"][room].rect.position.x + global.leveldata["rooms"][room].rect.size.x * 32
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_bottom = global.leveldata["rooms"][room].rect.position.y + global.leveldata["rooms"][room].rect.size.y * 32
	$roomsound.play()
func updatestats(hp: int = 0, atk: int = 0, def: int = 0) -> void:
	stats.hp += hp
	stats.atk += atk
	stats.def += def
	$ui/container/box/playerbox/level.text = "lvl" + str(stats.lvl)
	$ui/container/box/playerbox/stats.text = "hp: " + str(stats.hp) + "\natk: " + str(stats.atk) + "\ndef: " + str(stats.def)
