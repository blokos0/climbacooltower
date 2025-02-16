extends Node2D
var room: int = 0:
	set(val):
		room = val
		setuproom()
var stats: Dictionary = {
	"hp": 500.0,
	"maxhp": 500.0,
	"atk": 25.0,
	"def": 0.0,
	"lvl": 1
}
var theme: String = ""
var song: String = ""
func _ready() -> void:
	leveldatatolevel()
	DiscordRPC.state = "playing " + global.leveldata["name"]
	DiscordRPC.details = "placeholder"
	DiscordRPC.refresh()
	setuproom()
	updatestats()
func leveldatatolevel() -> void:
	# converts global.leveldata into a playable level
	var arr: PackedStringArray = global.leveldata["tiles"].split("/")
	if global.leveldata["tiles"] != "":
		for i in arr:
			var ind: int = int(i.get_slice(",", 0))
			var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
			var tm: TileMapLayer = $gamelayer/gameworldcontainer/gameworld/shader/floors
			if int(i.get_slice(",", 3)):
				tm = $gamelayer/gameworldcontainer/gameworld/shader/walls
			tm.set_cell(pos, 0, Vector2i(ind, int(i.get_slice(",", 3))))
	$gamelayer/gameworldcontainer/gameworld/shader/player.position = global.leveldata["playerspawn"] * 32
	global.enemies = global.leveldata["enemydata"]
	for i: Dictionary in global.leveldata["enemyplace"]:
		var e: Sprite2D = preload("res://scenes/enemy.tscn").instantiate()
		e.position = i[0] * 32
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
func _process(_delta: float) -> void:
	$gamelayer/gameworldcontainer/gameworld/shader/camera.position = Vector2($gamelayer/gameworldcontainer/gameworld/shader/player.position.x + 16, $gamelayer/gameworldcontainer/gameworld/shader/player.position.y - 16) + $gamelayer/gameworldcontainer/gameworld/shader/player.offset
	if Input.is_action_just_pressed(&"playtest"):
		get_tree().change_scene_to_file("res://scenes/editor.tscn")
func setuproom() -> void:
	if global.leveldata["rooms"].is_empty():
		return
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
		$music.stream.set_sync_stream(0, load("res://music/" + global.leveldata["rooms"][room].song + ".ogg"))
		$music.stream.set_sync_stream(1, load("res://music/" + global.leveldata["rooms"][room].song + "_lowhp.ogg"))
		$music.play()
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_left = global.leveldata["rooms"][room].rect.position.x * 32 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_top = global.leveldata["rooms"][room].rect.position.y * 32 - max(352 - global.leveldata["rooms"][room].rect.size.y * 32, 0) / 2 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_right = global.leveldata["rooms"][room].rect.position.x * 32 + global.leveldata["rooms"][room].rect.size.x * 32 + max(352 - global.leveldata["rooms"][room].rect.size.x * 32, 0) / 2 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_bottom = global.leveldata["rooms"][room].rect.position.y * 32 + global.leveldata["rooms"][room].rect.size.y * 32 - 4
	$roomsound.play()
func updatestats(hp: int = 0, atk: int = 0, def: int = 0) -> void:
	stats.hp += hp
	stats.atk += atk
	stats.def += def
	if stats.hp <= 0:
		stats.hp = 0
		$music.volume_db = -80
		$ui/container/box/playerbox/playerportrait.texture.region.position.y = 200
		$gamelayer/gameworldcontainer/gameworld/shader/player.visible = false
	elif stats.hp < stats.maxhp * 0.1:
		$music.stream.set_sync_stream_volume(0, -60)
		$music.stream.set_sync_stream_volume(1, 0)
		$ui/container/box/playerbox/playerportrait.texture.region.position.y = 100
	else:
		$music.stream.set_sync_stream_volume(0, 0)
		$music.stream.set_sync_stream_volume(1, -60)
		$ui/container/box/playerbox/playerportrait.texture.region.position.y = 0
	$ui/container/box/playerbox/level.text = "lvl" + str(stats.lvl)
	$ui/container/box/playerbox/stats.text = "hp: " + str(stats.hp) + "/" + str(stats.maxhp) + "\natk: " + str(stats.atk) + "\ndef: " + str(stats.def)
