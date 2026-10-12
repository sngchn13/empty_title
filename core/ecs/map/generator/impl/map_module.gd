## 빈자리에 끼우는 조각. 정사각형이어야 하고!!!, 안에 빈자리가 또 있을 수 있다
class_name MapModule
extends MapBlueprint

var kind: ModuleSlot.Kind


func to_save() -> Dictionary:
	var data := super.to_save()
	data["kind"] = ModuleSlot.Kind.find_key(kind)
	return data


func load_save(data: Dictionary) -> void:
	super.load_save(data)
	if size.x != size.y:
		push_error("Module must be square: %s" % size)
	if not data.has("kind"):
		push_error("Module needs a kind")
		return
	kind = ModuleSlot.parse_kind(data["kind"])


## 정사각형이라 한 변으로 충분하다. 빈자리와 맞는지 볼 때 쓴다
func get_side() -> int:
	return size.x
