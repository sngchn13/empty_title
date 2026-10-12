## 맵을 이루는 조각의 공통 부분. MapLayout과 MapModule로 나뉜다.
## 빈자리(slots)에 모듈을 끼워 맵을 만든다. 끼운 모듈에도 빈자리가 있으면 이어서 채운다
@abstract
class_name MapBlueprint
extends RefCounted

var size: Vector2i                          ## 바닥 크기. x는 x 방향, y는 z 방향 칸 수
var entities: Array[Dictionary] = []        ## 엔티티 하나 = 컴포넌트 이름 → 그 컴포넌트의 to_save() 결과
var slots: Array[ModuleSlot] = []           ## 모듈을 끼울 빈자리. 파일에 적힌 순서대로 채운다


func to_save() -> Dictionary:
	return {
		"size": JsonValue.from_vector2i(size),
		"entities": entities,
		"slots": slots.map(func(s): return s.to_save()),
	}


func load_save(data: Dictionary) -> void:
	size = JsonValue.to_vector2i(data["size"])
	entities.assign(data["entities"])
	slots.clear()
	for slot_data: Dictionary in data.get("slots", []):
		var slot := ModuleSlot.new()
		slot.load_save(slot_data)
		slots.append(slot)
