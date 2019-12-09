extends Node

class_name ResourceManager

const loader_pkg = preload("res://ResourceManager/InteractiveLoader.tscn")

static func load_resource(res_path, enable_bg = false) -> Resource:
	var loader = loader_pkg.instance()
	loader.enable_background = enable_bg
	if SceneManager.current_scene != null :
		SceneManager.current_scene.add_child(loader)
		loader.add_resource(res_path)
		loader.start_load()
		yield(loader,"loading_all_completed")
		var map_res = loader.get_path_resource_map()
		var res = map_res.get(map_res)
		loader.queue_free()
		return res
	
	return null

static func load_interactive_resource(res_path, enable_bg = false) :
	var loader = loader_pkg.instance()
	loader.enable_background = enable_bg
	if SceneManager.current_scene != null :
		SceneManager.current_scene.add_child(loader)
		loader.add_resource(res_path)
		loader.start_load()
		return loader
	
	return null

static func create_loader() :
	return loader_pkg.instance()
