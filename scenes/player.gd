extends Sprite2D
var dirs: Dictionary = {
	"left": Vector2(-1, 0),
	"right": Vector2(1, 0),
	"up": Vector2(0, -1),
	"down": Vector2(0, 1)
}
var lastdir: Vector2 = dirs.down
var dirspressed: PackedVector2Array
var movetimer: int
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
			var invalidtile: bool = $"../walls".get_cell_atlas_coords(floor(position / 32)) != Vector2i(-1, -1) || $"../floors".get_cell_atlas_coords(floor(position / 32)) == Vector2i(-1, -1)
			$shapecast.force_shapecast_update()
			if $shapecast.is_colliding():
				var i: Object = $shapecast.get_collider(0)
				if i.is_in_group(&"teleporter"):
					$/root/play.room = i.get_node("..").roomid
					position = ($/root/play.rooms[i.get_node("..").roomid].pos + i.get_node("..").pos) * 32
				elif i.is_in_group(&"enemy"):
					invalidtile = true
					var estats: Dictionary = formenemystats(i.get_node(".."))
					var vals: Dictionary = global.calcbattlevalues($/root/play.stats, estats)
					if vals.turncount > 0:
						$/root/play.updatestats(-vals.damage)
						i.get_node("..").free()
			if invalidtile:
				position -= dirspressed[-1] * 32
				offset += dirspressed[-1] * 32
			else:
				$walksound.play()
		lastdir = dirspressed[-1]
		$raycast.target_position = lastdir * 32
		$raycast.force_raycast_update()
		var area: Area2D = $raycast.get_collider()
		if area != null && area.is_in_group(&"enemy"):
			$/root/play/ui/container/box/enemystuff.visible = true
			var e: Sprite2D = area.get_node("..")
			var spr: AtlasTexture = AtlasTexture.new()
			spr.atlas = e.texture
			spr.region = e.region_rect
			var estats: Dictionary = formenemystats(e)
			var vals: Dictionary = global.calcbattlevalues($/root/play.stats, estats)
			$/root/play/ui/container/box/enemystuff/enemyname.text = global.enemyvariants[e.variant] + " " + e.kind
			$/root/play/ui/container/box/enemystuff/enemybox/enemysprite.texture = spr
			$/root/play/ui/container/box/enemystuff/enemybox/stats.text = "hp: " + str(estats.hp) + "\natk: " + str(estats.atk) + "\ndef: " + str(estats.def) + "\ndamage: "
			if vals.turncount > 0:
				$/root/play/ui/container/box/enemystuff/enemybox/stats.text += str(vals.damage) + " (" + str(vals.turncount) + " turns"
			else:
				$/root/play/ui/container/box/enemystuff/enemybox/stats.text += "invalid"
		else:
			$/root/play/ui/container/box/enemystuff.visible = false
	movetimer = max(movetimer - 1, 0)
	offset = lerp(offset, Vector2(0, -16), 0.5)
func moveinput(inp: String) -> void:
	if Input.is_action_just_pressed(inp):
		if !dirspressed.has(dirs[inp]):
			dirspressed.append(dirs[inp])
			movetimer = 0
	if Input.is_action_just_released(inp) && dirspressed.size():
		dirspressed.remove_at(dirspressed.find(dirs[inp]))
func formenemystats(enemy: Sprite2D):
	return {
		"hp": global.enemies.get(enemy.kind).hp[enemy.variant],
		"atk": global.enemies.get(enemy.kind).atk[enemy.variant],
		"def": global.enemies.get(enemy.kind).def[enemy.variant],
	}
