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
var rooms: Array[Dictionary] = []
var placingenemy: bool:
	set(val):
		placingenemy = val
		$ui/tooltipthing.text = "place the " + global.enemyvariants[currentenemyvariant] + " " + placingenemykind
		$ui/tooltipthing.visible = placingenemy
var didthepaneljustclose: bool # i hate this
var placingenemykind: String
var placedenemies: Array[Array]
func _ready() -> void:
	$ui/panel/uibox/propertiesbox/tileroombox/roomtheme.select(0)
	$ui/panel/uibox/propertiesbox/tileroombox/roomsong.select(0)
	genenemylist()
	DiscordRPC.state = "in the editor"
	DiscordRPC.large_image = "icon"
	DiscordRPC.refresh()
func _process(_delta: float) -> void:
	if !$ui/panel.visible && $ui/fuckingeditorthing.get_local_mouse_position().y > 0 && !selectingroom && !placingenemy:
		$ui/panel.visible = true
		$ui/fuckingeditorthing.visible = false
	elif $ui/fuckingeditorthing.get_local_mouse_position().y < -328:
		$ui/panel.visible = false
		$ui/fuckingeditorthing.visible = true
	var tm: TileMapLayer = $floors
	$walls.modulate.a = 0.5
	$floors.modulate.a = 1
	if currenttile.y == 1:
		tm = $walls
		$walls.modulate.a = 1
		$floors.modulate.a = 0.5
	if Input.is_action_pressed(&"showasis") && !$ui/panel.visible:
		$walls.modulate.a = 1
		$floors.modulate.a = 1
	if Input.is_action_pressed(&"placetile"):
		if $ui/panel.visible:
			if Input.is_action_just_pressed(&"placetile"):
				if mouseintexturerect($ui/panel/uibox/tiles):
					currenttile = floor($ui/panel/uibox/tiles.get_local_mouse_position() / 32)
					$ui/panel/uibox/tiles/selectedtile.position = currenttile * 32
				elif mouseintexturerect($ui/panel/uibox/propertiesbox/enemybox/enemyvariants):
					var pos: Vector2 = floor($ui/panel/uibox/propertiesbox/enemybox/enemyvariants.get_local_mouse_position() / 32)
					currentenemyvariant = pos.x + pos.y * 4
					$ui/panel/uibox/propertiesbox/enemybox/enemyvariants/selectedenemyvariant.position = pos * 32
					genenemylist()
				elif $ui/panel/uibox/propertiesbox/tileroombox/createroom.is_hovered():
					$ui/panel.visible = false
					$ui/fuckingeditorthing.visible = true
					selectingroom = true
		elif !selectingroom && !placingenemy:
			tm.set_cell(floor(get_local_mouse_position() / 32), 0, currenttile)
		elif selectingroom:
			if Input.is_action_just_pressed(&"placetile"):
				selectedroom = Rect2i(floor(get_local_mouse_position() / 32), Vector2i(0, 0))
			elif selectedroom != null:
				selectedroom.size = Vector2i(ceil(get_local_mouse_position() / 32)) - selectedroom.position
	if Input.is_action_just_pressed("placetile") && placingenemy && !$ui/panel.visible && !didthepaneljustclose:
		var pe: Array = [floor(get_local_mouse_position() / 32), placingenemykind, currentenemyvariant]
		var invalid: bool = placedenemies.has(pe)
		for i in placedenemies:
			if i[0] == floor(get_local_mouse_position() / 32):
				invalid = true
		if !invalid:
			placedenemies.append(pe)
		placingenemy = false
		print(placedenemies)
	didthepaneljustclose = false
	if Input.is_action_just_released(&"placetile") && selectedroom != null:
		if selectedroom.abs().has_area():
			selectedroom = selectedroom.abs()
			selectingroom = false
			rooms.append({
				"name": $ui/panel/uibox/propertiesbox/tileroombox/roomname.text,
				"rect": selectedroom,
				"theme": $ui/panel/uibox/propertiesbox/tileroombox/roomtheme.get_item_text($ui/panel/uibox/propertiesbox/tileroombox/roomtheme.get_selected_items()[0]),
				"song": $ui/panel/uibox/propertiesbox/tileroombox/roomsong.get_item_text($ui/panel/uibox/propertiesbox/tileroombox/roomsong.get_selected_items()[0])
			})
			selectedroom = null
			var roomname: String = " " # for easier selecting
			if $ui/panel/uibox/propertiesbox/tileroombox/roomname.text != "":
				roomname = $ui/panel/uibox/propertiesbox/tileroombox/roomname.text
			$ui/panel/uibox/propertiesbox/otherbox/roomlist.add_item(roomname)
		else:
			$ui/tooltipthing.text = "sorry its too flat"
	if Input.is_action_pressed(&"removetile"):
		tm.erase_cell(floor(get_local_mouse_position() / 32))
	if !$ui/panel.visible:
		$camera.position += Input.get_vector(&"left", &"right", &"up", &"down") * 12 * (int(Input.is_action_pressed("sneak")) + 1) * (0.5 / $camera.zoom.x + 0.5)
		if Input.is_action_just_pressed(&"zoomin") || Input.is_action_just_pressed(&"zoomout"):
			var cammouse: Vector2 = get_global_mouse_position()
			var zoomval: float = 1 + (int(Input.is_action_just_pressed(&"zoomin")) - int(Input.is_action_just_pressed(&"zoomout"))) * 0.2
			$camera.zoom = clamp($camera.zoom * Vector2(zoomval, zoomval), Vector2(0.03125, 0.03125), Vector2(4, 4))
			$camera/grid.modulate.a = lerpf(0.25, 0, 0.25 / $camera.zoom.x)
			$camera.position += cammouse - get_global_mouse_position()
		$camera/grid.region_rect.position = $camera.position
	if Input.is_action_just_pressed(&"ui_copy"):
		var arr: PackedStringArray = []
		for pos in $floors.get_used_cells():
			var i: int = $floors.get_cell_atlas_coords(pos).x
			arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y))
		var strr: String = "/".join(arr)
		global.leveldata["floors"] = strr
		arr = []
		for pos in $walls.get_used_cells():
			var i: int = $walls.get_cell_atlas_coords(pos).x
			arr.append(str(i) + "," + str(pos.x) + "," + str(pos.y))
		strr = "/".join(arr)
		global.leveldata["walls"] = strr
		global.leveldata["rooms"] = rooms
		var towername: String = "tower"
		if len($ui/panel/uibox/propertiesbox/otherbox/towername.text):
			towername = $ui/panel/uibox/propertiesbox/otherbox/towername.text
		global.leveldata["name"] = towername
		DiscordRPC.details = "making " + towername
		DiscordRPC.refresh()
		global.leveldata["enemyplace"] = placedenemies
		var file: FileAccess = FileAccess.open("user://" + towername.validate_filename() + ".cact", FileAccess.WRITE)
		if file:
			file.store_buffer(str(global.leveldata).to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP))
			global.notify("saved")
		else:
			global.notify("failed to save!!")
	if Input.is_action_just_pressed(&"ui_paste"):
		var file: PackedByteArray = FileAccess.get_file_as_bytes("user://tower.cact")
		print(file.decompress_dynamic(100000000, FileAccess.COMPRESSION_GZIP).get_string_from_utf8())
	queue_redraw()
func _draw() -> void:
	if !$ui/panel.visible && !selectingroom && !placingenemy:
		draw_texture_rect_region(preload("res://sprites/tiles.png"), Rect2(floor(get_local_mouse_position() / 32) * 32, Vector2(32, 32)), Rect2(currenttile * 32, Vector2i(32, 32)), Color(1, 1, 1, 0.5))
	if selectedroom != null:
		draw_rect(Rect2i(selectedroom.position * 32, selectedroom.size * 32), Color.RED, false, 4)
	var ind: int = 0
	for i in rooms:
		draw_rect(Rect2i(i.rect.position * 32, i.rect.size * 32), Color.from_hsv(ind * 0.027, 1, 1), false, 8)
		draw_string(ThemeDB.fallback_font, i.rect.position * 32 - Vector2i(0, 24), i.name)
		ind += 1
	for i in placedenemies:
		draw_texture_rect_region(load("res://sprites/" + i[1] + ".png"), Rect2(i[0] * 32, Vector2(32, 32)), Rect2(i[2] * 32, 0, 32, 32))
func _on_roomlist_item_activated(index: int) -> void:
	$ui/panel/uibox/propertiesbox/otherbox/roomlist.remove_item(index)
	rooms.remove_at(index)
func _on_enemylist_item_activated(index: int) -> void:
	placingenemykind = global.enemies.keys()[index]
	$ui/panel.visible = false
	$ui/fuckingeditorthing.visible = true
	placingenemy = true
	didthepaneljustclose = true
	$ui/panel/uibox/propertiesbox/enemybox/enemylist.get_item_icon(index) # this will be useful for drawing the preview
	$ui/panel/uibox/propertiesbox/enemybox/enemylist.deselect_all()
func mouseintexturerect(t: TextureRect) -> bool:
	return Rect2(Vector2(0, 0), t.texture.get_size()).has_point(t.get_local_mouse_position())
func genenemylist() -> void:
	var sel: PackedInt32Array = $ui/panel/uibox/propertiesbox/enemybox/enemylist.get_selected_items()
	$ui/panel/uibox/propertiesbox/enemybox/enemylist.clear()
	for i in global.enemies.keys():
		var t: AtlasTexture = AtlasTexture.new()
		t.atlas = load("res://sprites/" + i + ".png")
		t.region = Rect2(currentenemyvariant * 32, 0, 32, 32)
		$ui/panel/uibox/propertiesbox/enemybox/enemylist.add_item(global.enemyvariants[currentenemyvariant] + " " + i, t)
	if sel:
		$ui/panel/uibox/propertiesbox/enemybox/enemylist.select(sel[0])
