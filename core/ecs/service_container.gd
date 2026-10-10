class_name ServiceContainer
extends RefCounted

const EXCLUDED_PATH := "res://test/"

var repository: EntityRepository
var _services: Dictionary[Script, Service] = {}


func _init() -> void:
	repository = EntityRepository.new()
	_set_services()


func get_service(type: Script) -> Service:
	var service: Service = _services.get(type)
	if service == null:
		push_error("Service not registered: %s" % type.get_global_name())
	return service


static func _get_service_dict() -> Dictionary[StringName, GDScript]:
	var found: Dictionary[StringName, String] = {}
	for info in ProjectSettings.get_global_class_list():
		var base: StringName = info["base"]
		var path: String = info["path"]
		if base != &"Service" or path.begins_with(EXCLUDED_PATH):
			continue
		found[info["class"]] = path

	var names: Array[StringName] = []
	names.assign(found.keys())
	names.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))

	var out: Dictionary[StringName, GDScript] = {}
	for cls in names:
		out[cls] = load(found[cls]) as GDScript
	return out


func _set_services() -> void:
	var dict := _get_service_dict()
	print("", dict)	#todo: 삭제
	for cls: StringName in dict:
		var mold: GDScript = dict[cls]
		_services[mold] = mold.new(repository)
