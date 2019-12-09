extends CanvasLayer


signal loading()
signal loading_completed(res)
signal loading_all_completed(res_map)
signal loading_error(error)
signal update_progress(val)

export(PoolStringArray) var path_pull : PoolStringArray = []
export(bool) var enable_emit_update = false
export(bool) var enable_print_log = true
export(bool) var enable_background = true

var debug = false

var interactive_resource_pull : Dictionary = {}
var resource_completed : Dictionary = {}
var is_start = false
var is_completed = false
var completed_count = 0
var progress = 0

onready var background_node = $Control/Background
onready var background_inner_node = $Control/Background/Background
var start_pos_x
var offset_x
var end_pos_x
var marning_r

func _ready():
	if not enable_background :
		$Control/Background.hide()
	set_process(false)
	self.connect("loading_error", self, "_print_log")
	
	start_pos_x = background_inner_node.rect_position.x - (background_inner_node.rect_size.x * 0.5)
	offset_x = start_pos_x
	end_pos_x =  background_inner_node.rect_position.x + background_node.rect_size.x - (background_inner_node.rect_size.x * 0.5)
	marning_r = background_inner_node.margin_right
	if debug :
		set_process(true)
	
	pass # Replace with function body.

func start_load() :
	
	interactive_resource_pull.clear()
	
	_print_log("Loading")
	for path in path_pull :
		if interactive_resource_pull.has(path) :
			emit_signal("loading_error", "Resource %s load dublicate" % str(path))
			continue
		else :
			var interactive = ResourceLoader.load_interactive(path)
			interactive_resource_pull[path] = interactive
	
	set_process(true)
	is_start = true
	emit_signal("loading")
	pass

func add_resource(path) -> bool :
	if not ResourceLoader.exists(path) :
		emit_signal("loading_error", "Not found resource " + str(path)) 
		return false
	
	path_pull.append(path)
	return true

func get_resources() -> Array :
	return resource_completed.values()

func get_path_resource_map() -> Dictionary :
	return resource_completed


func _update_progress(val) :
	if enable_emit_update :
		emit_signal("update_progress", val)
	$Control/ProgressBar.value = val
	
	if enable_background :
		var progress_x = end_pos_x * (progress / 100) + start_pos_x
		offset_x = progress_x
		background_inner_node.rect_position.x = offset_x
		background_inner_node.margin_left = offset_x
		background_inner_node.margin_right = marning_r + offset_x
	
	
	pass


func _print_log(text) :
	if enable_print_log :
		$Control/Log.add_text(text + "\n")

func _process(delta):
	
	if debug :
		progress += delta
		_update_progress(progress)
	elif is_start and not is_completed :
		var count = interactive_resource_pull.size()
		var stage_size = 100.0 / count
		
		progress = 0
		completed_count = 0
		for key in interactive_resource_pull.keys() :
			var val = interactive_resource_pull[key]
			if val is ResourceInteractiveLoader :
				var err = val.poll()
				if err == ERR_FILE_EOF :
					progress += stage_size
					completed_count += 1
					if not resource_completed.has(key) :
						resource_completed[key] = val.get_resource()
						emit_signal("loading_completed", resource_completed[key])
						_print_log("Loading %s competed!" % str(key))
				elif err == OK:
					var stage_count = val.get_stage_count()
					var stage = val.get_stage()
					if stage != 0 and stage_count != 0 :
						var progress_stage = stage / stage_count
						progress += stage_size * progress_stage
				else :
					completed_count += 1
					emit_signal("loading_error", "Resource %s load failed! Error #%s" % [str(key), str(err)])
		
		_update_progress(progress)
		if completed_count == interactive_resource_pull.size() :
			is_completed = false
			is_start = false
			emit_signal("loading_all_completed", resource_completed)
			_print_log("Loading all completed")
			set_process(false)
		
	pass