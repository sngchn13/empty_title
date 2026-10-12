## 레이아웃이나 모듈 안의 빈자리. 맵을 만드는 동안에만 쓰고 저장소에는 들어가지 않는다
class_name ModuleSlot
extends RefCounted

enum Kind { BUILDING, OPEN }    ## 모듈 종류.

var cell: Vector3i                          ## x, z가 가장 작은 모서리 칸. 청사진 기준 좌표
var side: int                               ## 한 변의 칸 수
var kinds: Array[Kind] = []                 ## 받는 모듈 종류. 비어 있으면 모든 종류
var facings: Array[GridConst.Facing] = []   ## 허용하는 방향. 비어 있으면 모든 방향


func to_save() -> Dictionary:
	return {
		"cell": JsonValue.from_vector3i(cell),
		"side": side,
		"kinds": kinds.map(func(k): return Kind.find_key(k)),
		"facings": facings.map(func(f): return GridConst.Facing.find_key(f)),
	}


func load_save(data: Dictionary) -> void:
	cell = JsonValue.to_vector3i(data["cell"])
	side = int(data["side"])
	kinds.assign(data.get("kinds", []).map(func(n): return parse_kind(n)))
	facings.assign(data.get("facings", []).map(func(n): return GridConst.parse_facing(n)))


## JSON에 적힌 이름을 Kind로 바꾼다
static func parse_kind(kind_name: String) -> Kind:
	if not Kind.has(kind_name):
		push_error("Unknown module kind: %s" % kind_name)
		return Kind.BUILDING
	return Kind[kind_name]
