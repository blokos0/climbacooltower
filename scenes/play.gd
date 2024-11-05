extends Node2D
var rooms: Array[Dictionary]:
	set(val):
		rooms = val
var room: int = 0:
	set(val):
		room = val
		setuproom()
var stats: Dictionary = {
	"hp": 500.0,
	"atk": 25.0,
	"def": 0.0,
	"lvl": 1
}
var theme: String = "digital"
func _ready() -> void:
	setuproom()
	updatestats()
	var bg: CanvasLayer = load("res://scenes/bg" + theme + ".tscn").instantiate()
	add_child(bg)
	move_child(bg, 2)
	if theme == "snowy":
		$gamelayer/gameworldcontainer/gameworld/shader.material = ShaderMaterial.new()
		$gamelayer/gameworldcontainer/gameworld/shader.material.shader = preload("res://shaders/glitch.gdshader")
		$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_power", 0.003)
		$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_rate", 1)
		$gamelayer/gameworldcontainer/gameworld/shader.material.set_shader_parameter(&"shake_color_rate", 0.005)
func setuproom() -> void:
	if !rooms.is_empty():
		$ui/container/box/roomname.text = rooms[room].name
		$camera.position = rooms[room].pos * 32 + Vector2i(316, 176)
	$roomsound.play()
func updatestats(hp: int = 0, atk: int = 0, def: int = 0) -> void:
	stats.hp += hp
	stats.atk += atk
	stats.def += def
	$ui/container/box/playerbox/level.text = "lvl" + str(stats.lvl)
	$ui/container/box/playerbox/stats.text = "hp: " + str(stats.hp) + "\natk: " + str(stats.atk) + "\ndef: " + str(stats.def)
