extends Node2D
var currenttile: Vector2i
var menuopen: bool
var selectingroom: bool:
	set(val):
		selectingroom = val
		$ui/selectingroom.visible = selectingroom
var selectedroom: Variant
var rooms: Array[Dictionary] = []
func _ready() -> void:
	%roomtheme.select(0)
	%roomsong.select(0)
func _process(_delta: float) -> void:
	if !$ui/panel.visible && $ui/fuckingeditorthing.get_local_mouse_position().y > 0 && !selectingroom:
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
			if Rect2($ui/panel/uibox/tiles.position, $ui/panel/uibox/tiles.texture.get_size()).has_point($ui/panel/uibox/tiles.get_local_mouse_position()):
				currenttile = floor($ui/panel/uibox/tiles.get_local_mouse_position() / 32)
				$ui/panel/uibox/tiles/selectedtile.position = currenttile * 32
			elif $ui/panel/uibox/propertiesbox/tileroombox/createroom.is_hovered():
				$ui/panel.visible = false
				$ui/fuckingeditorthing.visible = true
				selectingroom = true
		elif !selectingroom:
			tm.set_cell(floor(get_local_mouse_position() / 32), 0, currenttile)
		else:
			if Input.is_action_just_pressed(&"placetile"):
				selectedroom = Rect2i(floor(get_local_mouse_position() / 32), Vector2i(0, 0))
			elif selectedroom != null:
				selectedroom.size = Vector2i(ceil(get_local_mouse_position() / 32)) - selectedroom.position
	if Input.is_action_just_released(&"placetile") && selectedroom != null && selectedroom.abs().has_area():
		selectedroom = selectedroom.abs()
		selectingroom = false
		rooms.append({
			"name": %roomname.text,
			"rect": selectedroom,
			"theme": %roomtheme.get_item_text(%roomtheme.get_selected_items()[0]),
			"song": %roomsong.get_item_text(%roomsong.get_selected_items()[0])
		})
		selectedroom = null
		var roomname: String = " " # for easier selecting
		if %roomname.text != "":
			roomname = %roomname.text
		%roomlist.add_item(roomname)
	if Input.is_action_pressed(&"removetile"):
		tm.erase_cell(floor(get_local_mouse_position() / 32))
	if !$ui/panel.visible:
		$camera.position += Input.get_vector(&"left", &"right", &"up", &"down") * 12
		if Input.is_action_just_pressed(&"zoomin") || Input.is_action_just_pressed(&"zoomout"):
			var cammouse: Vector2 = get_global_mouse_position()
			var zoomval: float = (int(Input.is_action_just_pressed(&"zoomin")) - int(Input.is_action_just_pressed(&"zoomout"))) * 0.1
			$camera.zoom = clamp($camera.zoom + Vector2(zoomval, zoomval), Vector2(0.125, 0.125), Vector2(4, 4))
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
		if len(%towername.text):
			towername = %towername.text
		global.leveldata["name"] = towername
		var file: FileAccess = FileAccess.open("user://" + towername + ".txt", FileAccess.WRITE)
		file.store_string(JSON.stringify(global.leveldata, "	"))
		OS.shell_open(file.get_path_absolute())
	queue_redraw()
func _draw() -> void:
	if !$ui/panel.visible && !selectingroom:
		draw_texture_rect_region(preload("res://sprites/tiles.png"), Rect2(floor(get_local_mouse_position() / 32) * 32, Vector2(32, 32)), Rect2(currenttile * 32, Vector2i(32, 32)), Color(1, 1, 1, 0.5))
	if selectedroom != null:
		draw_rect(Rect2i(selectedroom.position * 32, selectedroom.size * 32), Color.RED, false, 4)
	var ind: int = 0
	for i in rooms:
		draw_rect(Rect2i(i.rect.position * 32, i.rect.size * 32), Color.from_hsv(ind * 0.027, 1, 1), false, 8)
		draw_string(ThemeDB.fallback_font, i.rect.position * 32 - Vector2i(0, 24), i.name)
		ind += 1
func _on_roomlist_item_activated(index: int) -> void:
	%roomlist.remove_item(index)
	rooms.remove_at(index)
