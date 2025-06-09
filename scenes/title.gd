extends Node2D
var menus: PackedVector2Array = [Vector2(0, 0), Vector2(640, 0)]
var menu: int
func _ready() -> void:
	$homebox/startbutton.grab_focus()
	$homebox/startbutton.pressed.connect(startbuttonpressed)
	$homebox/createbutton.pressed.connect(createbuttonpressed)
	$homebox/browsebutton.pressed.connect(browsebuttonpressed)
	$homebox/settingsbutton.pressed.connect(settingsbuttonpressed)
	$createbox/backbutton.pressed.connect(createbackbuttonpressed)
	$createbox/newtowerbutton.pressed.connect(createnewtowerbuttonpressed)
	$createbox/edittowerbutton.pressed.connect(createnewtowerbuttonpressed.bind(false))
	$"/root".gui_focus_changed.connect(focuschanged)
	$credits.text = "v" + global.version + " [wave freq=5][rainbow sat=0.5 freq=0.1]made by blokos"
	DiscordRPC.state = "on the titlescreen"
	DiscordRPC.details = "yeah"
	DiscordRPC.refresh()
func _process(_delta: float) -> void:
	$logo.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32) * 6, 130 + sin(float(Engine.get_process_frames()) / 16) * 3)
	$logotrail.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32 + 1) * 8, 130 + sin(float(Engine.get_process_frames()) / 16 + 1) * 5)
	$logotrail.modulate = Color.from_hsv(float(Engine.get_process_frames()) / 256, 1, 3, 0.5)
	$bghome.region_rect = Rect2(float(Engine.get_process_frames()) / 4, 0, 640, 360)
	$camera.position = lerp($camera.position, menus[menu], 0.1)
	if Input.is_action_just_pressed(&"back") && menu != 0:
		menu = 0
		$homebox/startbutton.grab_focus()
		$focussound.play()
func startbuttonpressed() -> void:
	get_tree().change_scene_to_file("res://scenes/storymode.tscn")
func createbuttonpressed() -> void:
	menu = 1
	$createbox/backbutton.grab_focus()
func browsebuttonpressed() -> void:
	global.notify("epic placeholder")
func settingsbuttonpressed() -> void:
	pass
func createbackbuttonpressed() -> void:
	menu = 0
	$homebox/startbutton.grab_focus()
func createnewtowerbuttonpressed(reset: bool = true) -> void:
	if reset:
		global.leveldata.clear()
	print(global.leveldata)
	get_tree().change_scene_to_file("res://scenes/editor.tscn")
func focuschanged(node: Control) -> void:
	if !Input.is_action_just_pressed(&"placetile"):
		$focussound.play()
	if !menu:
		$art.texture = load("res://sprites/menuart_" + node.name + ".png")
