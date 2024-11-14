extends Sprite2D
var pages: PackedStringArray
var events: String
var talker: String
var silent: bool
var page: int
var talking: bool = true
var talkspeed: float = 1
var punctpause: float = 1
var vischar: float
var face: int
func _ready() -> void:
	$text.text = pages[page]
	loadtalker()
func _process(_delta: float) -> void:
	if talking:
		if $text.visible_characters >= len($text.get_parsed_text()):
			if Input.is_action_just_pressed(&"dialog"):
				page += 1
				if page == len(pages):
					queue_free()
				else:
					vischar = 0
					$text.visible_characters = 0
					$text.text = pages[page]
					talkspeed = 1
		else:
			var talkspeedreal: float = talkspeed / punctpause
			vischar = min(vischar + talkspeedreal, len(pages[page]))
			for i in events.split("/"):
				if int(vischar) == int(i.get_slice(",", 0)) && page == int(i.get_slice(",", 1)):
					match i.get_slice(",", 2):
						"stop":
							talking = false
						"speed":
							talkspeed = float(i.get_slice(",", 3))
						"talker":
							talker = i.get_slice(",", 3)
							loadtalker()
						"face":
							face = int(i.get_slice(",", 3))
						"silent":
							if i.get_slice(",", 3) == "true":
								silent = true
							else:
								silent = false
						_:
							print("unknown event detected at position " + str(int(vischar)) + ", p" + str(page) + ": " + i.get_slice(",", 2))
			if Input.is_action_just_pressed("dialog"):
				vischar = len($text.get_parsed_text())
			var curvischar: String = $text.get_parsed_text()[min(vischar, len($text.get_parsed_text())) - 1]
			if ".,!?:;".contains(curvischar):
				punctpause = 10 - (1 - talkspeed) * 8
			else:
				punctpause = 1
			if int(vischar) != $text.visible_characters && !silent && !".,:; \n".contains(curvischar):
				$noise.play()
			$text.visible_characters = int(vischar)
	$portrait.texture.region = Rect2i(wrap(floor(float(Engine.get_process_frames()) / 20) * 100, 0, 300), face * 100, 100, 100)
	if Input.is_action_just_pressed("dialog"):
		talking = true
		if talkspeed / punctpause < 1:
			vischar += 1
func loadtalker() -> void:
	face = 0
	$noise.stream.set_stream(0, load("res://sounds/diasound_" + talker + ".ogg"))
	if talker != "":
		$portrait.visible = true
		$portrait.texture.atlas = load("res://sprites/" + talker + "portrait.png")
	else:
		$portrait.visible = false
	$text.position.x = 9 + 100 * int(talker != "")
	$text.size.x = 622 - 100 * int(talker != "")
