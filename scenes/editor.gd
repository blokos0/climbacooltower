extends Node2D
var currenttile: Vector2i
var currentenemyvariant: float
var menuopen: bool
var selectingroom: bool:
	set(val):
		selectingroom = val
		$ui/tooltipthing.text = "selecting room"
		$ui/tooltipthing.visible = selectingroom
var selectedroom: Variant
var rooms: Array
var placingenemy: bool:
	set(val):
		placingenemy = val
		$ui/tooltipthing.text = "place the " + global.enemyvariants[currentenemyvariant] + " " + placingenemykind
		$ui/tooltipthing.visible = placingenemy
var didthepaneljustclose: bool # i hate this
var placingenemykind: String
var placingenemytexture: Texture2D
var placedenemies: Array
var placingjelly: bool
var playerpos: Vector2i
var panelpage: int
func _ready() -> void:
	$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.item_activated.connect(roomlistselect)
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.item_activated.connect(enemylistselect)
	$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/jellybutton.pressed.connect(jellybuttonpressed)
	$backuptimer.timeout.connect(savelevel.bind("backup"))
	$ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.select(0)
	$ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.select(0)
	genenemylist()
	DiscordRPC.state = "in the editor"
	DiscordRPC.details = "havent saved yet..."
	DiscordRPC.refresh()
	leveldatatolevel()
func _process(_delta: float) -> void:
	if !$ui/panel.visible && $ui/fuckingeditorthing.get_local_mouse_position().y > 0 && !selectingroom && !placingenemy && !placingjelly:
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
	elif !$ui/panel.visible && !selectingroom && !placingenemy && !placingjelly:
		$ui/fuckingeditorthing.visible = true
	if Input.is_action_pressed(&"placetile"):
		if $ui/panel.visible:
			if Input.is_action_just_pressed(&"placetile") && $ui/panel/uiboxp0.visible:
				if mouseintexturerect($ui/panel/uiboxp0/tiles):
					currenttile = floor($ui/panel/uiboxp0/tiles.get_local_mouse_position() / 32)
					$ui/panel/uiboxp0/tiles/selectedtile.position = currenttile * 32
				elif mouseintexturerect($ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants):
					var pos: Vector2 = floor($ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants.get_local_mouse_position() / 32)
					currentenemyvariant = pos.x + pos.y * 4
					$ui/panel/uiboxp0/propertiesbox/enemybox/enemyvariants/selectedenemyvariant.position = pos * 32
					genenemylist()
				elif $ui/panel/uiboxp0/propertiesbox/tileroombox/createroom.is_hovered():
					$ui/panel.visible = false
					selectingroom = true
		elif !selectingroom && !placingenemy && !placingjelly:
			tm.set_cell(floor(get_local_mouse_position() / 32), 0, currenttile)
		elif selectingroom:
			if Input.is_action_just_pressed(&"placetile"):
				selectedroom = Rect2i(floor(get_local_mouse_position() / 32), Vector2i(0, 0))
			elif selectedroom != null:
				selectedroom.size = Vector2i(ceil(get_local_mouse_position() / 32)) - selectedroom.position
		elif placingjelly:
			playerpos = floor(get_local_mouse_position() / 32)
			placingjelly = false
			$ui/tooltipthing.visible = false
	if Input.is_action_just_pressed(&"placetile") && placingenemy && !$ui/panel.visible && !didthepaneljustclose:
		var pe: Array = [floor(get_local_mouse_position() / 32), placingenemykind, currentenemyvariant]
		var invalid: bool = placedenemies.has(pe)
		for i in placedenemies:
			if Vector2i(i[0]) == Vector2i(floor(get_local_mouse_position() / 32)): # i[0] is either Vector2 or Vector2i every time idk why
				invalid = true
		if !invalid:
			placedenemies.append(pe)
		placingenemy = false
	didthepaneljustclose = false
	if Input.is_action_just_released(&"placetile") && selectedroom != null:
		if selectedroom.abs().has_area():
			selectedroom = selectedroom.abs()
			selectingroom = false
			rooms.append({
				"name": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text,
				"rect": selectedroom,
				"theme": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.get_item_text($ui/panel/uiboxp0/propertiesbox/tileroombox/roomtheme.get_selected_items()[0]),
				"song": $ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.get_item_text($ui/panel/uiboxp0/propertiesbox/tileroombox/roomsong.get_selected_items()[0])
			})
			selectedroom = null
			var roomname: String = " " # for easier selecting
			if $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text != "":
				roomname = $ui/panel/uiboxp0/propertiesbox/tileroombox/roomname.text
			$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.add_item(roomname)
		else:
			$ui/tooltipthing.text = "sorry its too flat"
	if Input.is_action_pressed(&"removetile") && !$ui/panel.visible:
		tm.erase_cell(floor(get_local_mouse_position() / 32))
	if Input.is_action_just_pressed(&"picktile"):
		if tm.get_cell_source_id(floor(get_local_mouse_position() / 32)) != -1:
			currenttile.x = tm.get_cell_atlas_coords(floor(get_local_mouse_position() / 32)).x
			$ui/panel/uiboxp0/tiles/selectedtile.position = currenttile * 32
	if !$ui/panel.visible && !Input.is_action_pressed(&"save"):
		$camera.position += Input.get_vector(&"left", &"right", &"up", &"down") * 12 * (int(Input.is_action_pressed("sneak")) + 1) * (0.5 / $camera.zoom.x + 0.5)
		if Input.is_action_just_pressed(&"zoomin") || Input.is_action_just_pressed(&"zoomout"):
			var cammouse: Vector2 = get_global_mouse_position()
			var zoomval: float = 1 + (int(Input.is_action_just_pressed(&"zoomin")) - int(Input.is_action_just_pressed(&"zoomout"))) * 0.2
			$camera.zoom = clamp($camera.zoom * Vector2(zoomval, zoomval), Vector2(0.03125, 0.03125), Vector2(4, 4))
			$camera.position += cammouse - get_global_mouse_position()
		$camera/grid.region_rect.position = $camera.position
	if Input.is_action_just_pressed(&"page"):
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
			global.notify("failed to save!!")
		DiscordRPC.details = "making " + towername
		DiscordRPC.refresh()
	if Input.is_action_just_pressed(&"playtest"):
		if !rooms.is_empty():
			leveltoleveldata()
			get_tree().change_scene_to_file("res://scenes/play.tscn")
		else:
			global.notify("towers need to have atleast one room")
	if Input.is_action_just_pressed(&"back"):
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	queue_redraw()
func _draw() -> void:
	draw_texture(preload("res://sprites/jelly.png"), Vector2(playerpos.x * 32, playerpos.y * 32 - 16))
	if selectedroom != null:
		draw_rect(Rect2i(selectedroom.position * 32, selectedroom.size * 32), Color.RED, false, 4)
	if !(Input.is_action_pressed("showasis") && !$ui/panel.visible):
		var ind: int = 0
		for i in rooms:
			draw_rect(Rect2i(i.rect.position * 32, i.rect.size * 32), Color.from_hsv(ind * 0.027, 1, 1), false, 8)
			draw_string(ThemeDB.fallback_font, i.rect.position * 32 - Vector2i(0, 24), i.name)
			ind += 1
		if !$ui/panel.visible:
			if !selectingroom && !placingenemy && !placingjelly:
				draw_texture_rect_region(preload("res://sprites/tiles.png"), Rect2(floor(get_local_mouse_position() / 32) * 32, Vector2(32, 32)), Rect2(currenttile * 32, Vector2i(32, 32)), Color(1, 1, 1, 0.5))
			elif placingjelly:
				draw_texture(preload("res://sprites/jelly.png"), Vector2(floor(get_local_mouse_position().x / 32) * 32, floor(get_local_mouse_position().y / 32) * 32 - 16), Color(1, 1, 1, 0.5))
			elif placingenemy:
				draw_texture(placingenemytexture, floor(get_local_mouse_position() / 32) * 32, Color(1, 1, 1, 0.5))
	for i in placedenemies:
		draw_texture_rect_region(load("res://sprites/" + i[1] + ".png"), Rect2(i[0] * 32, Vector2(32, 32)), Rect2(i[2] * 32, 0, 32, 32), Color(1, 1, 1, 0.75 + int(Input.is_action_pressed("showasis") && !$ui/panel.visible) * 0.25))
func roomlistselect(index: int) -> void:
	$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.remove_item(index)
	rooms.remove_at(index)
func enemylistselect(index: int) -> void:
	placingenemykind = global.enemies.keys()[index]
	$ui/panel.visible = false
	placingenemy = true
	didthepaneljustclose = true
	placingenemytexture = $ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.get_item_icon(index)
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.deselect_all()
func jellybuttonpressed() -> void:
	placingjelly = true
	$ui/panel.visible = false
	didthepaneljustclose = true
	$ui/tooltipthing.text = "place jelly"
	$ui/tooltipthing.visible = true
func mouseintexturerect(t: TextureRect) -> bool:
	return Rect2(Vector2(0, 0), t.texture.get_size()).has_point(t.get_local_mouse_position())
func genenemylist() -> void:
	var sel: PackedInt32Array = $ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.get_selected_items()
	$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.clear()
	for i in global.enemies.keys():
		var t: AtlasTexture = AtlasTexture.new()
		t.atlas = load("res://sprites/" + i + ".png")
		t.region = Rect2(currentenemyvariant * 32, 0, 32, 32)
		$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.add_item(global.enemyvariants[currentenemyvariant] + " " + i, t)
	if sel:
		$ui/panel/uiboxp0/propertiesbox/enemybox/enemylist.select(sel[0])
func leveltoleveldata() -> void:
	# dumps the current editor level to global.leveldata
	var arr: PackedStringArray = []
	for pos in $floors.get_used_cells():
		var i: int = $floors.get_cell_atlas_coords(pos).x
		arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y) + ",0")
	for pos in $walls.get_used_cells():
		var i: int = $walls.get_cell_atlas_coords(pos).x
		arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y) + ",1")
	global.leveldata["tiles"] = "/".join(arr)
	var towername: String = "tower"
	if len($ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text):
		towername = $ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text
	global.leveldata["name"] = towername
	global.leveldata["rooms"] = rooms
	global.leveldata["playerspawn"] = playerpos
	# no teleporter support yet...
func leveldatatofile(filename: String) -> FileAccess:
	# does the necessary conversions and saves global.leveldata to a file, then reverts the changes
	var arr: PackedStringArray = []
	for r in rooms:
		arr.append(r.name + "," + str(r.rect.position.x) + "," + str(r.rect.position.y) + "," + str(r.rect.size.x) + "," + str(r.rect.size.y) + "," + r.theme + "," + r.song)
	global.leveldata["rooms"] = "/".join(arr)
	arr = []
	for e in placedenemies:
		arr.append(str(e[0].x) + "," + str(e[0].y) + "," + e[1] + "," + str(e[2]))
	global.leveldata["enemyplace"] = "/".join(arr)
	global.leveldata["playerspawn"] = str(playerpos.x) + "," + str(playerpos.y)
	var file: FileAccess = FileAccess.open("user://" + filename + ".cact", FileAccess.WRITE)
	if file:
		file.store_buffer(JSON.stringify(global.leveldata).to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP))
	global.leveldata["rooms"] = rooms
	global.leveldata["enemyplace"] = placedenemies
	global.leveldata["playerspawn"] = playerpos
	return file
	# no teleporter support yet...
func savelevel(filename: String) -> FileAccess:
	# leveltoleveldata() and leveldatatofile(filename) in one function
	leveltoleveldata()
	return leveldatatofile(filename)
func leveldatatolevel() -> void:
	# converts global.leveldata into an editor level
	rooms = global.leveldata["rooms"]
	for r in global.leveldata["rooms"]:
		var rnm = " " # for easier selecting
		if r.name != "":
			rnm = r.name
		$ui/panel/uiboxp0/propertiesbox/otherbox/roomlist.add_item(rnm)
	playerpos = global.leveldata["playerspawn"]
	if global.leveldata["tiles"] != "":
		for i in global.leveldata["tiles"].split("/"):
			var ind: int = int(i.get_slice(",", 0))
			var pos: Vector2i = Vector2i(int(i.get_slice(",", 1)), int(i.get_slice(",", 2)))
			var tm: TileMapLayer = $floors
			if int(i.get_slice(",", 3)):
				tm = $walls
			tm.set_cell(pos, 0, Vector2i(ind, int(i.get_slice(",", 3))))
	placedenemies = global.leveldata["enemyplace"]
	$ui/panel/uiboxp0/propertiesbox/otherbox/funbox/towername.text = global.leveldata["name"]
	# no teleporter support yet...
func loadlevel(filename: String) -> void:
	# global.filetoleveldata() and leveldatatolevel() in one function
	if global.filetoleveldata(filename):
		leveldatatolevel()
