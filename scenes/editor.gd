extends Node2D
var currenttile: Vector2i
var currentenemyvariant: float
var menuopen: bool
var selectingroom: bool
var selectedroom: Variant
var rooms: Array
var placingenemy: bool
var didthepaneljustclose: bool # i hate this
var placingenemykind: String
var placingenemytexture: Texture2D
var placedenemies: Array
var placingjelly: bool
var playerpos: Vector2i
var panelpage: int
var teleporterroom: String
var teleporterpos: Vector2i
var teleporteralt: bool
var placingteleporter: bool
var teleporters: Array
var startingroom: String
var rectanglestart: Vector2
var rectangleend: Vector2
func _ready() -> void:
	$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.item_activated.connect(roomlistselect)
	$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.item_selected.connect(roomlistclick)
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.item_activated.connect(enemylistselect)
	$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/jellybutton.pressed.connect(jellybuttonpressed)
	$ui/panel/uiboxp0/propertiesbox/tileroombox/createroom.pressed.connect(createroompressed)
	$ui/panel/uiboxp1/teleporterbox/positionbox/alt.pressed.connect(teleporteraltpressed)
	$ui/panel/uiboxp1/teleporterbox/teleporterplace.pressed.connect(createteleporterpressed)
	$backuptimer.timeout.connect(savelevel.bind("backup"))
	$ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.select(0)
	$ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.select(0)
	genenemylist()
	DiscordRPC.state = "in the editor"
	DiscordRPC.details = "havent saved yet..."
	DiscordRPC.refresh()
	if !global.leveldata.is_empty():
		leveldatatolevel()
func _process(_delta: float) -> void:
	if !$ui/panel.visible && $ui/fuckingeditorthing.get_local_mouse_position().y > 0 && !selectingroom && !placingenemy && !placingjelly && !Input.is_action_pressed(&"placetile") && !Input.is_action_pressed(&"rectangle"):
		$ui/panel.visible = true
		$ui/fuckingeditorthing.visible = false
	elif $ui/fuckingeditorthing.get_local_mouse_position().y < -328:
		$ui/panel.visible = false
	var tm: TileMapLayer = $floors
	$walls.modulate.a = 0.5
	$floors.modulate.a = 1
	$camera/grid.modulate.a = lerpf(0.25, 0, 0.25 / $camera.zoom.x)
	if currenttile.y == 1:
		tm = $walls
		$walls.modulate.a = 1
		$floors.modulate.a = 0.5
	if Input.is_action_pressed(&"showasis") && !$ui/panel.visible:
		$walls.modulate.a = 1
		$floors.modulate.a = 1
		$camera/grid.modulate.a = 0
		$ui/fuckingeditorthing.visible = false
	elif !$ui/panel.visible && !selectingroom && !placingenemy && !placingjelly && !placingteleporter:
		$ui/fuckingeditorthing.visible = true
	if Input.is_action_pressed(&"placetile"):
		if $ui/panel.visible:
			if Input.is_action_just_pressed(&"placetile") && $ui/panel/uiboxp0.visible:
				if mouseintexturerect($ui/panel/uiboxp0/tilescontainer/tiles):
					currenttile = floor($ui/panel/uiboxp0/tilescontainer/tiles.get_local_mouse_position() / 32)
					$ui/panel/uiboxp0/tilescontainer/tiles/selectedtile.position = currenttile * 32
				elif mouseintexturerect($ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants):
					var pos: Vector2 = floor($ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants.get_local_mouse_position() / 32)
					currentenemyvariant = pos.x + pos.y * 4
					$ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants/selectedenemyvariant.position = pos * 32
					genenemylist()
		elif !selectingroom && !placingenemy && !placingjelly && !placingteleporter && !Input.is_action_pressed(&"rectangle"):
			tm.set_cell(floor(get_local_mouse_position() / 32), 0, currenttile)
		elif selectingroom:
			if Input.is_action_just_pressed(&"placetile"):
				selectedroom = Rect2i(floor(get_local_mouse_position() / 32), Vector2i())
			elif selectedroom != null:
				selectedroom.size = Vector2i(ceil(get_local_mouse_position() / 32)) - selectedroom.position
		elif placingjelly:
			playerpos = floor(get_local_mouse_position() / 32)
			placingjelly = false
			$ui/tooltipthing.visible = false
		elif placingteleporter:
			var te: Array = [Vector2i(floor(get_local_mouse_position() / 32)), teleporterpos, teleporterroom, teleporteralt]
			var invalid: bool = teleporters.has(te) || checktelsandenemies(te[0])
			if !invalid:
				teleporters.append(te)
			placingteleporter = false
			$ui/tooltipthing.visible = false
	if Input.is_action_just_pressed(&"placetile") && placingenemy && !$ui/panel.visible && !didthepaneljustclose:
		var pe: Array = [Vector2i(floor(get_local_mouse_position() / 32)), placingenemykind, currentenemyvariant]
		var invalid: bool = placedenemies.has(pe) || checktelsandenemies(pe[0])
		if !invalid:
			placedenemies.append(pe)
		placingenemy = false
		$ui/tooltipthing.visible = false
	didthepaneljustclose = false
	if Input.is_action_just_released(&"placetile") && selectedroom != null:
		if selectedroom.abs().has_area():
			selectedroom = selectedroom.abs()
			selectingroom = false
			var r: Dictionary[String, Variant]
			r = {
				"name": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text,
				"rect": selectedroom,
				"theme": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.get_item_text($ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.get_selected_items()[0]),
				"song": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.get_item_text($ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.get_selected_items()[0])
			}
			rooms.append(r)
			selectedroom = null
			var roomname: String = " " # for easier selecting
			if $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text != "":
				roomname = $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text
			$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.add_item(roomname)
			$ui/tooltipthing.visible = false
		else:
			$ui/tooltipthing.text = "sorry its too flat"
	if Input.is_action_pressed(&"removetile") && !$ui/panel.visible:
		tm.erase_cell(floor(get_local_mouse_position() / 32))
	if Input.is_action_just_pressed(&"removetile") && !$ui/panel.visible:
		for i: Array in placedenemies:
			if i[0] == Vector2i(get_local_mouse_position() / 32):
				placedenemies.erase(i)
				break
		for i: Array in teleporters:
			if i[0] == Vector2i(get_local_mouse_position() / 32):
				teleporters.erase(i)
				break
	if Input.is_action_just_pressed(&"picktile"):
		if tm.get_cell_source_id(floor(get_local_mouse_position() / 32)) != -1:
			currenttile.x = tm.get_cell_atlas_coords(floor(get_local_mouse_position() / 32)).x
			$ui/panel/uiboxp0/tilescontainer/tiles/selectedtile.position = currenttile * 32
	if Input.is_action_just_pressed(&"tileswap") && !Input.is_action_pressed(&"rectangle") && !$ui/panel.visible:
		currenttile.y = int(!bool(currenttile.y))
		$ui/panel/uiboxp0/tilescontainer/tiles/selectedtile.position = currenttile * 32
	if Input.is_action_just_pressed(&"rectangle"):
		rectanglestart = floor(get_local_mouse_position() / 32)
	if Input.is_action_pressed(&"rectangle"):
		rectangleend = floor(get_local_mouse_position() / 32)
	if Input.is_action_just_released(&"rectangle"):
		# please forgive me
		var c: Vector2i = currenttile
		if Input.is_action_pressed(&"sneak"):
			c = Vector2i(-1, -1)
		for x: int in range(rectanglestart.x, rectangleend.x - sign(rectanglestart.x - rectangleend.x) + int(rectanglestart.x == rectangleend.x), clamp(sign(rectangleend.x - rectanglestart.x) + int(rectanglestart.x == rectangleend.x), -1, 1)):
			for y: int in range(rectanglestart.y, rectangleend.y - sign(rectanglestart.y - rectangleend.y) + int(rectanglestart.y == rectangleend.y), clamp(sign(rectangleend.y - rectanglestart.y) + int(rectanglestart.y == rectangleend.y), -1, 1)):
				tm.set_cell(Vector2i(x, y), 0, c)
	if !$ui/panel.visible && !Input.is_action_pressed(&"save"):
		$camera.position += Input.get_vector(&"left", &"right", &"up", &"down") * 12 * (int(Input.is_action_pressed("sneak")) + 1) * (0.5 / $camera.zoom.x + 0.5)
		if Input.is_action_just_pressed(&"zoomin") || Input.is_action_just_pressed(&"zoomout"):
			if Input.is_action_pressed(&"sneak"):
				currenttile.x = wrapi(currenttile.x + int(Input.is_action_just_pressed(&"zoomin")) - int(Input.is_action_just_pressed(&"zoomout")), 0, $ui/panel/uiboxp0/tilescontainer/tiles.texture.get_size().x / 32)
				$ui/panel/uiboxp0/tilescontainer/tiles/selectedtile.position = currenttile * 32
			else:
				var cammouse: Vector2 = get_global_mouse_position()
				var zoomval: float = 1 + (int(Input.is_action_just_pressed(&"zoomin")) - int(Input.is_action_just_pressed(&"zoomout"))) * 0.2
				$camera.zoom = clamp($camera.zoom * Vector2(zoomval, zoomval), Vector2(0.03125, 0.03125), Vector2(4, 4))
				$camera.position += cammouse - get_global_mouse_position()
		$camera/grid.region_rect.position = $camera.position
	if Input.is_action_just_pressed(&"page") && $ui/panel.visible && !$ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.has_focus() && !$ui/panel/uiboxp1/teleporterbox/room.has_focus() && !$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.has_focus() && !$ui/panel/uiboxp1/teleporterbox/positionbox/x.has_focus() && !$ui/panel/uiboxp1/teleporterbox/positionbox/y.has_focus() && !$ui/panel/uiboxp1/startroom.has_focus():
		$ui/panel.get_node("uiboxp" + str(panelpage)).visible = false
		panelpage = wrapi(panelpage + 1, 0, 2)
		$ui/panel.get_node("uiboxp" + str(panelpage)).visible = true
	if Input.is_action_just_pressed(&"save"):
		var towername: String = "tower"
		if len($ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text):
			towername = $ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text
		if savelevel(towername.validate_filename()):
			global.notify("saved")
		else:
			global.notify("failed to save!!!")
		DiscordRPC.details = "making " + towername
		DiscordRPC.refresh()
	if Input.is_action_just_pressed(&"playtest"):
		if !$ui/panel.visible:
			var sroom: bool
			for i: Dictionary in rooms:
				if i.name == startingroom:
					sroom = true
					break
			if rooms.size() == 1:
				sroom = true
				startingroom = rooms[0].name
			if !rooms.is_empty() && sroom:
				leveltoleveldata()
				get_tree().change_scene_to_file("res://scenes/play.tscn")
				return
			elif rooms.is_empty():
				global.notify("towers need to have atleast one room")
				createroompressed()
			elif !sroom:
				global.notify("the starting room doesnt exist")
		else:
			$ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.release_focus()
			$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.release_focus()
			$ui/panel/uiboxp1/teleporterbox/room.release_focus()
			$ui/panel/uiboxp1/teleporterbox/positionbox/x.release_focus()
			$ui/panel/uiboxp1/teleporterbox/positionbox/y.release_focus()
			$ui/panel/uiboxp1/startroom.release_focus()
	if Input.is_action_just_pressed(&"back"):
		leveltoleveldata()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		return
	$ui/tilepos.text = str(Vector2i(floor(get_local_mouse_position() / 32)))
	$ui/tilepos.visible = !$ui/panel.visible && !Input.is_action_pressed(&"showasis")
	startingroom = $ui/panel/uiboxp1/startroom.text
	queue_redraw()
func _draw() -> void:
	draw_texture_rect_region(preload("res://sprites/jelly.png"), Rect2i(playerpos.x * 32, playerpos.y * 32 - 32, 32, 64), Rect2i(0, 0, 32, 64))
	if selectedroom != null:
		draw_rect(Rect2i(selectedroom.position * 32, selectedroom.size * 32), Color.RED, false, 4)
	if !(Input.is_action_pressed("showasis") && !$ui/panel.visible):
		var ind: int = 0
		for i: Dictionary in rooms:
			draw_rect(Rect2i(i.rect.position * 32, i.rect.size * 32), Color.from_hsv(ind * 0.027, 1, 1), false, 8)
			draw_string(ThemeDB.fallback_font, i.rect.position * 32 - Vector2i(0, 24), i.name)
			ind += 1
		if !$ui/panel.visible && !Input.is_action_pressed(&"rectangle"):
			if !selectingroom && !placingenemy && !placingjelly && !placingteleporter:
				draw_texture_rect_region(preload("res://sprites/tiles.png"), Rect2(floor(get_local_mouse_position() / 32) * 32, Vector2(32, 32)), Rect2(currenttile * 32, Vector2i(32, 32)), Color(1, 1, 1, 0.5))
			elif placingjelly:
				draw_texture_rect_region(preload("res://sprites/jelly.png"), Rect2i(floor(get_local_mouse_position().x / 32) * 32, floor(get_local_mouse_position().y / 32) * 32 - 32, 32, 64), Rect2i(0, 0, 32, 64), Color(1, 1, 1, 0.5))
			elif placingenemy:
				draw_texture(placingenemytexture, floor(get_local_mouse_position() / 32) * 32, Color(1, 1, 1, 0.5))
			elif placingteleporter:
				draw_texture_rect_region(preload("res://sprites/teleporter.png"), Rect2(floor(get_local_mouse_position() / 32) * 32, Vector2(32, 32)), Rect2(Vector2i(wrap(floor(float(Engine.get_process_frames()) / 12.5) * 32, 0, 96), 32 * int(teleporteralt)), Vector2i(32, 32)), Color(1, 1, 1, 0.5))
	for i: Array in placedenemies:
		draw_texture_rect_region(load("res://sprites/" + i[1] + ".png"), Rect2(i[0] * 32, Vector2(32, 32)), Rect2(i[2] * 32, 0, 32, 32), Color(1, 1, 1, 0.75 + int(Input.is_action_pressed("showasis") && !$ui/panel.visible) * 0.25))
	for i: Array in teleporters:
		draw_texture_rect_region(preload("res://sprites/teleporter.png"), Rect2(i[0] * 32, Vector2i(32, 32)), Rect2(Vector2i(wrap(floor(float(Engine.get_process_frames()) / 12.5) * 32, 0, 96), 32 * int(i[3])), Vector2i(32, 32)), Color(1, 1, 1, 0.75 + int(Input.is_action_pressed("showasis") && !$ui/panel.visible) * 0.25))
	if Input.is_action_pressed(&"rectangle"):
		var rect: Rect2
		rect.position.x = rectanglestart.x * 32 - maxf((rectanglestart.x - rectangleend.x) * 32, 0)
		rect.position.y = rectanglestart.y * 32 - maxf((rectanglestart.y - rectangleend.y) * 32, 0)
		rect.end.x = rectangleend.x * 32 + 32 + maxf((rectanglestart.x - rectangleend.x) * 32, 0)
		rect.end.y = rectangleend.y * 32 + 32 + maxf((rectanglestart.y - rectangleend.y) * 32, 0)
		draw_rect(rect, Color(1, 1 - int(Input.is_action_pressed(&"sneak")), 1 - int(Input.is_action_pressed(&"sneak"))), false, 8)
func roomlistselect(index: int) -> void:
	$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.remove_item(index)
	rooms.remove_at(index)
func roomlistclick(index: int) -> void:
	$ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text = rooms[index].name
	# aw seriously
	for i: int in $ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.item_count:
		if $ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.get_item_text(i) == rooms[index].theme:
			$ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.select(i)
			break
	for i: int in $ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.item_count:
		if $ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.get_item_text(i) == rooms[index].song:
			$ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.select(i)
			break
func enemylistselect(index: int) -> void:
	placingenemykind = global.enemies.keys()[index]
	$ui/panel.visible = false
	placingenemy = true
	didthepaneljustclose = true
	placingenemytexture = $ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.get_item_icon(index)
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.deselect_all()
	$ui/tooltipthing.text = "place the " + global.enemyvariants[currentenemyvariant] + " " + placingenemykind
	$ui/tooltipthing.visible = true
func jellybuttonpressed() -> void:
	placingjelly = true
	$ui/panel.visible = false
	didthepaneljustclose = true
	$ui/tooltipthing.text = "place jelly"
	$ui/tooltipthing.visible = true
func createroompressed() -> void:
	$ui/panel.visible = false
	selectingroom = true
	$ui/tooltipthing.visible = true
	$ui/tooltipthing.text = "selecting room"
func teleporteraltpressed() -> void:
	teleporteralt = !teleporteralt
	$ui/panel/uiboxp1/teleporterbox/positionbox/alt.icon.region.position.y = 32 * int(teleporteralt)
func createteleporterpressed() -> void:
	var real: bool
	for i: Dictionary in rooms:
		if i.name == $ui/panel/uiboxp1/teleporterbox/room.text:
			real = true
			break
	if !real:
		global.notify("this room doesnt exist")
		return
	if !$ui/panel/uiboxp1/teleporterbox/positionbox/x.text.is_valid_int() || !$ui/panel/uiboxp1/teleporterbox/positionbox/y.text.is_valid_int():
		global.notify("invalid target position")
		return
	teleporterroom = $ui/panel/uiboxp1/teleporterbox/room.text
	teleporterpos = Vector2i(int($ui/panel/uiboxp1/teleporterbox/positionbox/x.text), int($ui/panel/uiboxp1/teleporterbox/positionbox/y.text))
	prints(teleporterroom, teleporterpos, teleporteralt)
	$ui/tooltipthing.visible = true
	$ui/tooltipthing.text = "place the teleporter"
	$ui/panel.visible = false
	placingteleporter = true
func mouseintexturerect(t: TextureRect) -> bool:
	return Rect2(Vector2(0, 0), t.texture.get_size()).has_point(t.get_local_mouse_position())
func genenemylist() -> void:
	var sel: PackedInt32Array = $ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.get_selected_items()
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.clear()
	for i: String in global.enemies.keys():
		var t: AtlasTexture = AtlasTexture.new()
		t.atlas = load("res://sprites/" + i + ".png")
		t.region = Rect2(currentenemyvariant * 32, 0, 32, 32)
		$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.add_item(global.enemyvariants[currentenemyvariant] + " " + i, t)
	if sel:
		$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.select(sel[0])
func leveltoleveldata() -> void:
	# dumps the current editor level to global.leveldata
	var arr: PackedStringArray = []
	for pos: Vector2i in $floors.get_used_cells():
		var i: int = $floors.get_cell_atlas_coords(pos).x
		arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y) + ",0")
	for pos: Vector2i in $walls.get_used_cells():
		var i: int = $walls.get_cell_atlas_coords(pos).x
		arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y) + ",1")
	global.leveldata["tiles"] = "/".join(arr)
	global.leveldata["name"] = $ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text
	global.leveldata["rooms"] = rooms
	global.leveldata["playerspawn"] = playerpos
	global.leveldata["teleporters"] = teleporters
	global.leveldata["startingroom"] = startingroom
	global.leveldata["enemyplace"] = placedenemies
	global.leveldata["enemydata"] = global.enemies
func leveldatatofile(filename: String) -> FileAccess:
	# does the necessary conversions and saves global.leveldata to a file, then reverts the changes
	var arr: PackedStringArray = []
	for r: Dictionary in rooms:
		arr.append(r.name + "," + str(r.rect.position.x) + "," + str(r.rect.position.y) + "," + str(r.rect.size.x) + "," + str(r.rect.size.y) + "," + r.theme + "," + r.song)
	global.leveldata["rooms"] = "/".join(arr)
	arr = []
	for e: Array in placedenemies:
		arr.append(str(e[0].x) + "," + str(e[0].y) + "," + e[1] + "," + str(e[2]))
	global.leveldata["enemyplace"] = "/".join(arr)
	arr = []
	for t: Array in teleporters:
		arr.append(str(t[0].x) + "," + str(t[0].y) + "," + str(t[1].x) + "," + str(t[1].y) + "," + str(t[2]) + "," + str(int(t[3])))
	global.leveldata["teleporters"] = "/".join(arr)
	global.leveldata["playerspawn"] = str(playerpos.x) + "," + str(playerpos.y)
	var file: FileAccess = FileAccess.open("user://" + filename + ".cact", FileAccess.WRITE)
	if file:
		file.store_buffer(JSON.stringify(global.leveldata).to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP))
	global.leveldata["rooms"] = rooms
	global.leveldata["enemyplace"] = placedenemies
	global.leveldata["playerspawn"] = playerpos
	global.leveldata["teleporters"] = teleporters
	return file
func savelevel(filename: String) -> FileAccess:
	# leveltoleveldata() and leveldatatofile(filename) in one function
	leveltoleveldata()
	return leveldatatofile(filename)
func leveldatatolevel() -> void:
	# converts global.leveldata into an editor level
	rooms = global.leveldata["rooms"]
	for r: Dictionary in global.leveldata["rooms"]:
		var rnm: String = " " # for easier selecting
		if r.name != "":
			rnm = r.name
		$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.add_item(rnm)
	playerpos = global.leveldata["playerspawn"]
	if global.leveldata["tiles"] != "":
		for i: String in global.leveldata["tiles"].split("/"):
			var ind: int = int(i.get_slice(",", 0))
			var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
			var tm: TileMapLayer = $floors
			if int(i.get_slice(",", 3)):
				tm = $walls
			tm.set_cell(pos, 0, Vector2i(ind, int(i.get_slice(",", 3))))
	placedenemies = global.leveldata["enemyplace"]
	teleporters = global.leveldata["teleporters"]
	startingroom = global.leveldata["startingroom"]
	$ui/panel/uiboxp1/startroom.text = startingroom
	$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text = global.leveldata["name"]
func loadlevel(filename: String) -> void:
	# global.filetoleveldata() and leveldatatolevel() in one function
	if global.filetoleveldata(filename):
		leveldatatolevel()
func checktelsandenemies(p: Vector2i) -> bool:
	for i: Array in teleporters:
		if i[0] == p:
			return true
	for i: Array in placedenemies:
		if i[0] == p:
			return true
	return false
