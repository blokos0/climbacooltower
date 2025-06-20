extends Sprite2D
var dirs: Dictionary[String, Vector2] = {
	"down": Vector2(0, 1),
	"right": Vector2(1, 0),
	"up": Vector2(0, -1),
	"left": Vector2(-1, 0)
}
var lastdir: Vector2 = dirs.down
var dirspressed: PackedVector2Array
var movetimer: int
var steps: int
func _process(_delta: float) -> void:
	moveinput(&"left")
	moveinput(&"right")
	moveinput(&"up")
	moveinput(&"down")
	if dirspressed.size() && !movetimer:
		movetimer = 5
		if !Input.is_action_pressed(&"sneak"):
			position += dirspressed[-1] * 32
			offset -= dirspressed[-1] * 32
			var invalidtile: bool = $"../walls".get_cell_atlas_coords(floor(position / 32)) != Vector2i(-1, -1) || $"../floors".get_cell_atlas_coords(floor(position / 32)) == Vector2i(-1, -1) || !visible
			if !global.leveldata["rooms"].is_empty() && !$/root/play.roomdict.rect.has_point(floor(position / 32)):
				invalidtile = true
			$shapecast.force_shapecast_update()
			if $shapecast.is_colliding():
				var i: Object = $shapecast.get_collider(0)
				if i.is_in_group(&"teleporter"):
					$/root/play.room = i.get_node("..").room
					$/root/play.setuproom()
					position = i.get_node("..").pos * 32
				elif i.is_in_group(&"enemy"):
					invalidtile = true
					var estats: Dictionary[String, float] = formenemystats(i.get_node(".."))
					var vals: Dictionary[String, float] = global.calcbattlevalues($/root/play.stats, estats)
					if vals.turncount > 0:
						$/root/play.updatestats(-vals.damage)
						i.get_node("..").free()
			if invalidtile:
				position -= dirspressed[-1] * 32
				offset += dirspressed[-1] * 32
			else:
				$walksound.play()
				steps = wrapi(steps + 1, 0, 4)
				region_rect.position.x = steps * 32
		lastdir = dirspressed[-1]
		$raycast.target_position = lastdir * 32
		$raycast.force_raycast_update()
		region_rect.position.y = dirs.values().find(lastdir) * 64
		var area: Area2D = $raycast.get_collider()
		if area != null && area.is_in_group(&"enemy"):
			$/root/play/ui/container/box/enemystuff.visible = true
			var e: Sprite2D = area.get_node("..")
			var spr: AtlasTexture = AtlasTexture.new()
			spr.atlas = e.texture
			spr.region = e.region_rect
			var estats: Dictionary[String, float] = formenemystats(e)
			var vals: Dictionary[String, float] = global.calcbattlevalues($/root/play.stats, estats)
			$/root/play/ui/container/box/enemystuff/enemyname.text = global.enemyvariants[e.variant] + " " + e.kind
			$/root/play/ui/container/box/enemystuff/enemybox/enemysprite.texture = spr
			$/root/play/ui/container/box/enemystuff/enemybox/stats.text = "hp: " + str(int(estats.hp)) + "\natk: " + str(int(estats.atk)) + "\ndef: " + str(int(estats.def)) + "\ndamage: "
			if vals.turncount > 0:
				$/root/play/ui/container/box/enemystuff/enemybox/stats.text += str(int(vals.damage)) + " (" + str(int(vals.turncount)) + " turns"
			else:
				$/root/play/ui/container/box/enemystuff/enemybox/stats.text += "invalid"
		else:
			$/root/play/ui/container/box/enemystuff.visible = false
	movetimer = max(movetimer - 1, 0)
	offset = lerp(offset, Vector2(0, -32), 0.5)
func moveinput(inp: String) -> void:
	if Input.is_action_just_pressed(inp):
		if !dirspressed.has(dirs[inp]):
			dirspressed.append(dirs[inp])
			movetimer = 0
	if Input.is_action_just_released(inp) && dirspressed.size():
		dirspressed.remove_at(dirspressed.find(dirs[inp]))
func formenemystats(enemy: Sprite2D) -> Dictionary[String, float]:
	return {
		"hp": global.enemies.get(enemy.kind).hp[enemy.variant],
		"atk": global.enemies.get(enemy.kind).atk[enemy.variant],
		"def": global.enemies.get(enemy.kind).def[enemy.variant],
	}
