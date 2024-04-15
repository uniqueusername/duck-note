extends VBoxContainer

@export var file_selector: FileDialog # file save/open dialog
@onready var lanes = {} # map each lane to its checkboxes
var map: BitMap = BitMap.new() # raw map data

var lane_count: int = 6:
	set(value):
		if value < 4: return
		else: lane_count = value
var beats: int = 12
var lpb: int = 2 # lines per beat
var lines = beats * lpb # total number of lines

func _ready():
	initialize_map(lane_count)

# generate ui according to map metadata
func initialize_map(num_lanes: int):
	# clear existing lanes
	for lane in lanes.keys():
		lane.queue_free()
	lanes.clear()
	
	# create new lanes
	for i in range(num_lanes):
		var new_lane = HBoxContainer.new()
		new_lane.name = "lane" + str(i)
		lanes[new_lane] = []
		$lanes.add_child(new_lane)
	
	# create checkboxes
	for lane in lanes.keys():
		for line in range(lines):
			if line % 8 == 0 and line > 0: lane.add_child(VSeparator.new())
			var checkbox = CheckBox.new()
			lane.add_child(checkbox)
			lanes.get(lane).append(checkbox)
	
	map.create(Vector2i(num_lanes, lines))

# load a map from file
func load_map(path: String):
	map = load(path)
	
	for i in range(lanes.keys().size()):
		var boxes = lanes[lanes.keys()[i]]
		for j in range(boxes.size()):
			boxes[j].button_pressed = map.get_bit(i, j)

# save current editor state to a file
func save_map(path: String):
	for i in range(lanes.keys().size()):
		var boxes = lanes.get(lanes.keys()[i])
		for j in range(boxes.size()):
			map.set_bit(i, j, boxes[j].button_pressed)
	
	ResourceSaver.save(map, path)

func _on_save_pressed():
	file_selector.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_selector.show()

func _on_load_pressed():
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.show()

func _on_file_selected(path):
	if file_selector.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		save_map(path)
	elif file_selector.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		load_map(path)
	
	file_selector.hide()

func _on_minus_pressed():
	lane_count -= 2
	$lane_count/counter.text = str(lane_count)
	initialize_map(lane_count)

func _on_plus_pressed():
	lane_count += 2
	$lane_count/counter.text = str(lane_count)
	initialize_map(lane_count)
