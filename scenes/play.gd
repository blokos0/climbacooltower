@tool
extends Node2D
@export var rooms: Array[Dictionary]:
	set(val):
		if rooms != val && Engine.is_editor_hint():
			queue_redraw()
		rooms = val
var room: int = 0:
	set(val):
		room = val
		if !Engine.is_editor_hint():
			setuproom()
@export var stats: Dictionary = {
	"hp": 500.0,
	"atk": 25.0,
	"def": 0.0,
	"lvl": 1
}
@export var theme: String = "digital"
var time: float
func _ready() -> void:
	if !Engine.is_editor_hint():
		setuproom()
		updatestats()
		$ui/container/box/playername.text = global.playername
		var bg: CanvasLayer = load("res://scenes/bg" + theme + ".tscn").instantiate()
		add_child(bg)
		move_child(bg, 2)
		if theme == "snowy":
			$gamelayer/gameworldcontainer/gameworld/shader.material = ShaderMaterial.new()
			$gamelayer/gameworldcontainer/gameworld/shader.material.shader = preload("res://shaders/glitch.gdshader")
			$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_power", 0.003)
			$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_rate", 1)
			$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_color_rate", 0.005)
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += 1
	$ui/container/box/playerbox/playerportrait.texture.region = Rect2i(wrap(floor(time / 20) * 100, 0, 300), 0, 100, 100)
func _draw() -> void:
	if Engine.is_editor_hint():
		var roomlist: String = "rooms:\n"
		var ind: int = 0
		var highest: Vector2
		for i in rooms:
			draw_rect(Rect2i(i.pos * 32, Vector2i(352, 352)), Color.from_hsv(ind * 0.027, 1, 1), false, 4)
			draw_string(ThemeDB.fallback_font, i.pos * 32 + Vector2i(-12, 16), str(ind))
			roomlist += i.name + " " + str(i.pos) + "\n"
			if i.pos.y < highest.y:
				highest = i.pos
			ind += 1
		draw_multiline_string(ThemeDB.fallback_font, highest * 32 - Vector2(0, ThemeDB.fallback_font.get_multiline_string_size(roomlist).y - 12), roomlist)
func setuproom() -> void:
	$ui/container/box/roomname.text = rooms[room].name
	$camera.position = rooms[room].pos * 32 + Vector2i(316, 176)
	$roomsound.play()
func updatestats(hp: int = 0, atk: int = 0, def: int = 0) -> void:
	stats.hp += hp
	stats.atk += atk
	stats.def += def
	$ui/container/box/playerbox/level.text = "lvl" + str(stats.lvl)
	$ui/container/box/playerbox/stats.text = "hp: " + str(stats.hp) + "\natk: " + str(stats.atk) + "\ndef: " + str(stats.def)
