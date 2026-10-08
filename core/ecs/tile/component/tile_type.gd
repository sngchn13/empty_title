class_name TileType
extends Component

var _value: StringName

func _init(value: StringName = &"") -> void:
	_value = value
	
func get_value() -> StringName:
	return _value

func to_save() -> Dictionary:
	return { "_value": _value }
	
func load_save(data: Dictionary) -> void:
	var v: StringName = data["_value"]
	_value = v
