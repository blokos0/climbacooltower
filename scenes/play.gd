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
var theme: String = "digital"
func _ready() -> void:
	var file: PackedByteArray = FileAccess.get_file_as_bytes("user://the test tower #2.cact")
	global.leveldata = JSON.parse_string(file.decompress_dynamic(100000000, FileAccess.COMPRESSION_GZIP).get_string_from_utf8())
	print(global.leveldata)
	var arr: PackedStringArray = global.leveldata["floors"].split("/")
	for i in arr:
		var ind: int = int(i.get_slice(",", 0))
		var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
		$gamelayer/gameworldcontainer/gameworld/shader/floors.set_cell(pos, 0, Vector2i(ind, 0))
	arr = global.leveldata["walls"].split("/")
	for i in arr:
		var ind: int = int(i.get_slice(",", 0))
		var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
		$gamelayer/gameworldcontainer/gameworld/shader/walls.set_cell(pos, 0, Vector2i(ind, 1))
	$gamelayer/gameworldcontainer/gameworld/shader/player.position = str_to_var("Vector2i" + global.leveldata["playerspawn"]) * 32
	global.towername = global.leveldata["name"]
	global.enemies = global.leveldata["enemydata"]
	for i in global.leveldata["enemyplace"]:
		var e: Sprite2D = preload("res://scenes/enemy.tscn").instantiate()
		e.position = str_to_var("Vector2i" + i[0]) * 32
		e.kind = i[1]
		e.variant = i[2]
		$gamelayer/gameworldcontainer/gameworld/shader.add_child(e)
	arr = global.leveldata["teleporters"].split("/")
	for i in arr:
		var t: AnimatedSprite2D = preload("res://scenes/teleporter.tscn").instantiate()
		t.position = Vector2i(int(i.get_slice(",", 0)), int(i.get_slice(",", 1))) * 32
		t.pos = Vector2i(int(i.get_slice(",", 2)), int(i.get_slice(",", 3)))
		t.roomid = int(i.get_slice(",", 4))
		t.alt = bool(int(i.get_slice(",", 5)))
		$gamelayer/gameworldcontainer/gameworld/shader.add_child(t)
	$gamelayer/gameworldcontainer/gameworld/shader.move_child($gamelayer/gameworldcontainer/gameworld/shader/player, $gamelayer/gameworldcontainer/gameworld/shader.get_child_count())
	DiscordRPC.state = "playing " + global.towername
	DiscordRPC.details = "placeholder"
	DiscordRPC.refresh()
	setuproom()
	updatestats()
func _process(_delta: float) -> void:
	$gamelayer/gameworldcontainer/gameworld/shader/camera.position = $gamelayer/gameworldcontainer/gameworld/shader/player.position + $gamelayer/gameworldcontainer/gameworld/shader/player.offset
func setuproom() -> void:
	if !global.leveldata["rooms"].is_empty():
		$ui/container/box/roomname.text = global.leveldata["rooms"][room].name
		var bgprev = get_node_or_null("bg" + theme)
		if bgprev != null:
			bgprev.free()
		theme = global.leveldata["rooms"][room].theme
		if theme == "snowy":
			$gamelayer/gameworldcontainer/gameworld/shader.material = ShaderMaterial.new()
			$gamelayer/gameworldcontainer/gameworld/shader.material.shader = preload("res://shaders/glitch.gdshader")
		else:
			$gamelayer/gameworldcontainer/gameworld/shader.material = null
		var bg: CanvasLayer = load("res://scenes/bg" + theme + ".tscn").instantiate()
		add_child(bg)
		move_child(bg, 2)
		$music.stream = load("res://music/" + global.leveldata["rooms"][room].song + ".ogg")
		$music.play()
		$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_left = str_to_var(global.leveldata["rooms"][room].rect).position.x
		$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_top = str_to_var(global.leveldata["rooms"][room].rect).position.y
		$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_right = str_to_var(global.leveldata["rooms"][room].rect).position.x + str_to_var(global.leveldata["rooms"][room].rect).size.x * 32
		$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_bottom = str_to_var(global.leveldata["rooms"][room].rect).position.y + str_to_var(global.leveldata["rooms"][room].rect).size.y * 32
	$roomsound.play()
func updatestats(hp: int = 0, atk: int = 0, def: int = 0) -> void:
	stats.hp += hp
	stats.atk += atk
	stats.def += def
	$ui/container/box/playerbox/level.text = "lvl" + str(stats.lvl)
	$ui/container/box/playerbox/stats.text = "hp: " + str(stats.hp) + "\natk: " + str(stats.atk) + "\ndef: " + str(stats.def)
