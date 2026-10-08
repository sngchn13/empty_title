## 개체(int id)와 컴포넌트를 보관한다. 게임 규칙은 모른다.
##
## - 개체는 번호뿐이다. create()로 만들고 destroy()로 지운다
## - 컴포넌트는 Component를 상속한 클래스의 인스턴스다
## - 한 개체에 같은 종류의 컴포넌트는 하나만 붙는다
## - 컴포넌트 종류는 정확히 같은 클래스로만 구분한다 (상속을 따라가지 않는다)
class_name EntityRepository
extends RefCounted

## 컴포넌트 종류(틀) → (id → 컴포넌트)
var _stores: Dictionary[Script, Dictionary] = {}
## 한 번 쓴 번호는 다시 쓰지 않는다.
var _next_id: int = 1

## 나중에 cell -> component가 많이 필요하면 캐시나 만들자


# ── entity ──────────────────────────────

func create() -> int:
	var id := _next_id
	_next_id += 1
	return id


## 붙어 있던 컴포넌트를 전부 지운다
func destroy(id: int) -> void:
	for store: Dictionary in _stores.values():
		store.erase(id)


# ── component ───────────────────────────

## 같은 종류가 이미 붙어 있으면 덮어쓴다
func set_component(id: int, component: Component) -> void:
	if not _ensure(component != null, "Cannot set null component on entity %d" % id):
		return

	var type: Script = component.get_script()
	if not _stores.has(type):
		_stores[type] = {}
	_stores[type][id] = component


## 없으면 아무것도 안 한다
func remove_component(id: int, type: Script) -> void:
	var store: Dictionary = _stores.get(type, {})
	store.erase(id)


func has_component(id: int, type: Script) -> bool:
	var store: Dictionary = _stores.get(type, {})
	return store.has(id)


## 없으면 null. 받는 쪽에서 as로 바꿔 쓴다
func get_component(id: int, type: Script) -> Component:
	var store: Dictionary = _stores.get(type, {})
	return store.get(id) as Component


# ── query ───────────────────────────────

## with를 전부 갖고 without은 하나도 없는 개체들. 결과는 id 오름차순 (시드 재현용)
## with는 최소 하나 있어야 한다. 개체 목록을 따로 두지 않아서 조건 없이 전부를 찾을 수 없다
func query(with: Array[Script], without: Array[Script] = []) -> Array[int]:
	if not _ensure(not with.is_empty(), "Query needs at least one component in 'with'"):
		return []

	var required: Array[Dictionary] = []
	for type in with:
		if not _stores.has(type):
			return []    # 아무도 갖지 않은 컴포넌트를 요구했으니 결과는 없다
		required.append(_stores[type])

	var excluded: Array[Dictionary] = []
	for type in without:
		if _stores.has(type):
			excluded.append(_stores[type])

	# 가장 작은 저장소만 훑는다
	var base: Dictionary = required[0]
	for store in required:
		if store.size() < base.size():
			base = store

	var out: Array[int] = []
	for id: int in base:
		if _has_all(id, required) and not _has_any(id, excluded):
			out.append(id)
	out.sort()
	return out


# ── save & load ─────────────────────────

## 같은 id의 컴포넌트를 묶어 저장 데이터로 만든다.
## id 오름차순이라 같은 상태면 항상 같은 결과가 나온다
##
## { "next_id": 17, "entities": [ { "id": 1, "components": { "GridPosition": {...}, ... } }, ... ] }
func to_save() -> Dictionary:
	# id → 그 개체의 컴포넌트들
	var by_id: Dictionary[int, Array] = {}
	for store: Dictionary in _stores.values():
		for id: int in store:
			if not by_id.has(id):
				by_id[id] = []
			by_id[id].append(store[id])

	var ids: Array[int] = []
	ids.assign(by_id.keys())
	ids.sort()

	var entities: Array = []
	for id in ids:
		var components: Array[Component] = []
		components.assign(by_id[id])
		entities.append({"id": id, "components": ComponentCodec.encode(components)})

	return {"next_id": _next_id, "entities": entities}


## 저장소를 비우고 저장 데이터로 다시 채운다.
## 저장된 id를 그대로 쓴다. 다른 개체의 id를 들고 있는 컴포넌트가 그대로 맞게 하기 위해서다
func load_save(data: Dictionary) -> void:
	_stores.clear()
	_next_id = int(data["next_id"])
	for entry: Dictionary in data["entities"]:
		var id := int(entry["id"])
		_next_id = maxi(_next_id, id + 1)    # 세이브의 next_id가 틀려도 겹치지 않게
		for component in ComponentCodec.decode(entry["components"]):
			set_component(id, component)


# ── private ────────────────────────────────

static func _has_all(id: int, stores: Array[Dictionary]) -> bool:
	for store in stores:
		if not store.has(id):
			return false
	return true


static func _has_any(id: int, stores: Array[Dictionary]) -> bool:
	for store in stores:
		if store.has(id):
			return true
	return false


## 조건이 거짓이면 기록을 남긴다. 개발 중에는 assert로 멈춘다.
## 배포판에서는 assert가 사라지고 기록만 남는다
func _ensure(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
	assert(ok, message)
	return ok
