extends Node2D
var room: String = global.leveldata["startingroom"]
var roomdict: Dictionary
var stats: Dictionary[String, float] = {
	"hp": 500.0,
	"maxhp": 500.0,
	"atk": 25.0,
	"def": 0.0,
	"lvl": 1.0
}
var theme: String = ""
var song: String = ""
func _ready() -> void:
	$ui/container/box/playername.text = global.playername
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
	for i: Array in global.leveldata["enemyplace"]:
		var e: Sprite2D = preload("res://scenes/enemy.tscn").instantiate()
		e.position = i[0] * 32
		e.kind = i[1]
		e.variant = i[2]
		$gamelayer/gameworldcontainer/gameworld/shader.add_child(e)
	for i: Array in global.leveldata["teleporters"]:
		var t: Sprite2D = preload("res://scenes/teleporter.tscn").instantiate()
		t.position = i[0] * 32
		t.pos = i[1]
		t.room = i[2]
		t.alt = i[3]
		$gamelayer/gameworldcontainer/gameworld/shader.add_child(t)
	$gamelayer/gameworldcontainer/gameworld/shader.move_child($gamelayer/gameworldcontainer/gameworld/shader/player, $gamelayer/gameworldcontainer/gameworld/shader.get_child_count())
func _process(_delta: float) -> void:
	$ui/container/box/playerbox/playerportrait.texture.region.position.x = wrap(floor(float(Engine.get_process_frames()) / 20) * 100, 0, 300)
	$gamelayer/gameworldcontainer/gameworld/shader/camera.position = Vector2($gamelayer/gameworldcontainer/gameworld/shader/player.position.x + 16, $gamelayer/gameworldcontainer/gameworld/shader/player.position.y + 32) + $gamelayer/gameworldcontainer/gameworld/shader/player.offset
	if Input.is_action_just_pressed(&"playtest"):
		get_tree().change_scene_to_file("res://scenes/editor.tscn")
func setuproom() -> void:
	if global.leveldata["rooms"].is_empty():
		return
	roomdict = {}
	for i: Dictionary in global.leveldata["rooms"]:
		if i.name == room:
			roomdict = i
			break
	print(roomdict)
	if roomdict.is_empty():
		push_error("room not found: " + room)
		return
	$ui/container/box/roomname.text = roomdict.name
	if theme != roomdict.theme:
		$bg.free()
		theme = roomdict.theme
		var bg: CanvasLayer = load("res://scenes/bg" + theme + ".tscn").instantiate()
		add_child(bg)
		move_child(bg, 2)
		if theme == "snowy":
			$gamelayer/gameworldcontainer/gameworld/shader.material = ShaderMaterial.new()
			$gamelayer/gameworldcontainer/gameworld/shader.material.shader = preload("res://shaders/glitch.gdshader")
		else:
			$gamelayer/gameworldcontainer/gameworld/shader.material = null
	if song != roomdict.song:
		song = roomdict.song
		$music.stream.set_sync_stream(0, load("res://music/" + roomdict.song + ".ogg"))
		$music.stream.set_sync_stream(1, load("res://music/" + roomdict.song + "_lowhp.ogg"))
		$music.play()
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_left = roomdict.rect.position.x * 32 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_top = roomdict.rect.position.y * 32 - max(352 - roomdict.rect.size.y * 32, 0) / 2 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_right = roomdict.rect.position.x * 32 + roomdict.rect.size.x * 32 + max(352 - roomdict.rect.size.x * 32, 0) / 2 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.limit_bottom = roomdict.rect.position.y * 32 + roomdict.rect.size.y * 32 - 4
	$gamelayer/gameworldcontainer/gameworld/shader/camera.position = Vector2($gamelayer/gameworldcontainer/gameworld/shader/player.position.x + 16, $gamelayer/gameworldcontainer/gameworld/shader/player.position.y + 32) + $gamelayer/gameworldcontainer/gameworld/shader/player.offset
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
	$ui/container/box/playerbox/level.text = "lvl" + str(int(stats.lvl))
	$ui/container/box/playerbox/stats.text = "hp: " + str(int(stats.hp)) + "/" + str(int(stats.maxhp)) + "\natk: " + str(int(stats.atk)) + "\ndef: " + str(int(stats.def))
