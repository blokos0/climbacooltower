extends Node2D
var menus: PackedVector2Array = [Vector2(0, 0), Vector2(640, 0)]
var menu: int
func _ready() -> void:
	$homebox/startbutton.grab_focus()
	$homebox/startbutton.pressed.connect(startbuttonpressed)
	$homebox/createbutton.pressed.connect(createbuttonpressed)
	$homebox/browsebutton.pressed.connect(browsebuttonpressed)
	$homebox/settingsbutton.pressed.connect(settingsbuttonpressed)
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
	global.notify("not yet!")
func createbuttonpressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/editor.tscn")
	menu = 1
	$createbox/backbutton.grab_focus()
func browsebuttonpressed() -> void:
	global.notify("epic placeholder")
func settingsbuttonpressed() -> void:
	var d: Variant = global.setupdialog(["it is i! mr sad"], "8,0,stop/9,0,face,1", "holland")
	if d:
		add_child(d)
func focuschanged(node: Control) -> void:
	$focussound.play()
	if !menu:
		$art.texture = load("res://sprites/menuart_" + node.name + ".png")
	if $createbox/backbutton.has_focus():
		$art.texture = load("res://sprites/menuart_createbutton.png")
func _on_backbutton_pressed() -> void:
	menu = 0
	$homebox/startbutton.grab_focus()
	$focussound.play()
func _on_newtowerbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")
