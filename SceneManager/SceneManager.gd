extends Node

export(PackedScene) var transaction_pkg = preload("res://TransactionScene/TransactionScene.tscn")

var current_scene : Node = null
var root = null


func _ready():
    root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)

##############

func goto_scene_interactive_loader(path, enable_transaction = true) :
	call_deferred("_deferred_goto_scene_interactive_loader", path, enable_transaction)

func goto_scene(path, enable_transaction = true):
	call_deferred("_deferred_goto_scene", path, enable_transaction)

func goto_scene_instance(scene : Node, enable_transaction = true) :
	self.call_deferred("_deferred_goto_scene_instance", scene, enable_transaction)

###########

func _deferred_goto_scene_interactive_loader(path, enable_transaction = true) :
	var interactive_loader = ResourceManager.create_loader()
	interactive_loader.connect("loading_error", self, "_error_interactive")
	interactive_loader.connect("ready", self, "_interactive_loading_ready", [interactive_loader, path, enable_transaction])
	_deferred_goto_scene_instance(interactive_loader, enable_transaction)
	
	pass

func _interactive_loading_ready(interactive_loader, path, enable_transaction) :
	if not interactive_loader.add_resource(path) :
		printerr("SceneManager ERROR, %s in interactive load failed" % path)
	interactive_loader.call_deferred("start_load")
	yield(interactive_loader, "loading_all_completed")
	var res_map = interactive_loader.get_path_resource_map()
	var res = res_map[path]
	if res is PackedScene :
		var scene = res.instance()
		self.call_deferred("_deferred_goto_scene_instance", scene, enable_transaction)

func _error_interactive(err) :
	printerr(err)

############


func _deferred_goto_scene(path, enable_transaction = true):
	var scene = ResourceLoader.load(path).instance()
	goto_scene_instance(scene, enable_transaction)

func _deferred_goto_scene_instance(scene : Node, enable_transaction = true) :
	if current_scene != null and current_scene.is_inside_tree() :
		if enable_transaction and transaction_pkg != null:
			var trans : Node = transaction_pkg.instance()
			trans.to_show = false
			current_scene.add_child(trans)
			yield(trans,"tree_exited")
	
	if current_scene != null :
		current_scene.free()
		current_scene = null
	
	current_scene = scene
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	if current_scene != null and enable_transaction and transaction_pkg != null:
		var trans = transaction_pkg.instance()
		trans.to_show = true
		current_scene.add_child(trans)
	
