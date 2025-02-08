extends Node2D
func _ready() -> void:
	$box/startbutton.grab_focus()
	$box/startbutton.pressed.connect(startbuttonpressed)
	$box/createbutton.pressed.connect(createbuttonpressed)
	$box/browsebutton.pressed.connect(browsebuttonpressed)
	$box/settingsbutton.pressed.connect(settingsbuttonpressed)
	$"/root".gui_focus_changed.connect(focuschanged)
	$credits.text = "v" + global.version + " [wave freq=5][rainbow sat=0.5 freq=0.1]made by blokos"
	DiscordRPC.state = "on the titlescreen"
	DiscordRPC.details = "yeah"
	DiscordRPC.refresh()
func _process(_delta: float) -> void:
	$logo.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32) * 6, 130 + sin(float(Engine.get_process_frames()) / 16) * 3)
	$logotrail.position = Vector2(185 + sin(float(Engine.get_process_frames()) / 32 + 1) * 8, 130 + sin(float(Engine.get_process_frames()) / 16 + 1) * 5)
	$logotrail.modulate = Color.from_hsv(float(Engine.get_process_frames()) / 256, 1, 3, 0.5)
	$bg.region_rect = Rect2(float(Engine.get_process_frames()) / 4, 0, 640, 360)
func startbuttonpressed() -> void:
	global.notify("not yet!")
func createbuttonpressed() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")
func browsebuttonpressed() -> void:
	global.notify("epic placeholder")
func settingsbuttonpressed() -> void:
	var d: Variant = global.setupdialog(["it is i! mr sad"], "8,0,stop/9,0,face,1", "holland")
	if d:
		add_child(d)
func focuschanged(node: Control) -> void:
	$focussound.play()
	$art.texture = load("res://sprites/menuart_" + node.name + ".png")
