## 청크 하나.
class_name Chunk
extends RefCounted

var size: Vector3i
var entities: Array[Dictionary] = []

func to_save() -> Dictionary:
	return {"size": JsonValue.from_vector3i(size), "entities": entities}


func load_save(data: Dictionary) -> void:
	size = JsonValue.to_vector3i(data["size"])
	entities.assign(data["entities"])
