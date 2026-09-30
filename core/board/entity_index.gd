## Entity들의 위치 정보를 기록한 것.
## 게임 규칙은 모른다. 기록이 깨지지 않게 막는 검사만 한다.
class_name EntityIndex
extends RefCounted

var _tiles: Dictionary[Vector3i, Tile] = {}

var _units: Dictionary[Vector3i, Unit] = {}
var _units_at: Dictionary[Unit, Vector3i] = {}

# Occupant 대신 Prop으로 만든다. Unit이 Occupant를 상속하므로
# 슬롯 타입이 Occupant면 유닛이 설치물 칸에 들어갈 수 있다.
#var _props: Dictionary[Vector3i, Array] = {}
#var _props_at: Dictionary[Prop, Vector3i] = {}


# ── Tile: 칸으로 다룬다 ─────────────────

## 없으면 null
func tile_at(cell: Vector3i) -> Tile:
	return _tiles.get(cell)


func has_tile(cell: Vector3i) -> bool:
	return _tiles.has(cell)


## 빈 칸에만 넣는다. 교체는 swap_tile로 한다
func put_tile(tile: Tile, cell: Vector3i) -> void:
	if not _ensure(not has_tile(cell), "Tile already exists at %s" % cell):
		return

	_tiles.set(cell, tile)


## 뺀 타일을 돌려준다. 없으면 null
func take_tile(cell: Vector3i) -> Tile:
	var out: Tile = _tiles.get(cell)
	_tiles.erase(cell)
	return out


## 원래 타일을 돌려준다. 없었으면 null
func swap_tile(tile: Tile, cell: Vector3i) -> Tile:
	var out: Tile = take_tile(cell)
	_tiles.set(cell, tile)
	return out


## keys()는 타입 없는 배열이라 assign으로 옮긴다
func all_tile_cells() -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	out.assign(_tiles.keys())
	return out


# ── Unit: 객체로 다룬다 ─────────────────

## 다중 칸 유닛은 어느 칸을 물어도 같은 유닛. 없으면 null
func unit_at(cell: Vector3i) -> Unit:
	return _units.get(cell)


func has_unit_at(cell: Vector3i) -> bool:
	return _units.has(cell)


func is_unit_placed(unit: Unit) -> bool:
	return _units_at.has(unit)


## 기준 칸. 부르는 쪽이 is_unit_placed로 먼저 확인한다
## 보드에 없는 유닛이면 assert (Vector3i는 null이 될 수 없다)
func origin_cell_of(unit: Unit) -> Vector3i:
	assert(is_unit_placed(unit), "Unit is not placed on the board")
	return _units_at[unit]


## 차지하는 칸 전부. 보드에 없으면 빈 배열
func occupied_cells_of(unit: Unit) -> Array[Vector3i]:
	if not is_unit_placed(unit):
		return []
	return unit.size.footprint_at(_units_at[unit])


## 기준 칸이 cell일 때 차지할 칸이 전부 비어 있는가.
## 자기 자신이 차지한 칸은 빈 칸으로 본다. 그래서 옮길 때도 쓸 수 있다
func can_put_unit(unit: Unit, cell: Vector3i) -> bool:
	for c in unit.size.footprint_at(cell):
		var other: Unit = _units.get(c)
		if other != null and other != unit:
			return false
	return true


## 규칙 검사는 BoardManager가 먼저 한다.
## 여기서 걸리면 BoardManager가 검사를 빠뜨렸다는 뜻이다
func put_unit(unit: Unit, cell: Vector3i) -> void:
	if not _ensure(not is_unit_placed(unit), "Unit is already placed"):
		return
	if not _ensure(can_put_unit(unit, cell), "Cannot put unit, cell is blocked: %s" % cell):
		return

	for c in unit.size.footprint_at(cell):
		_units.set(c, unit)
	_units_at.set(unit, cell)


## 보드에 없으면 아무것도 안 한다
func take_unit(unit: Unit) -> void:
	if not is_unit_placed(unit):
		return

	for c in occupied_cells_of(unit):    # _units_at을 지우기 전에 부른다
		_units.erase(c)
	_units_at.erase(unit)


## _units_at은 키를 지우지 않고 값만 바꾼다 (순서 유지)
func relocate_unit(unit: Unit, to: Vector3i) -> void:
	if not _ensure(is_unit_placed(unit), "Cannot relocate, unit is not placed"):
		return
	if not _ensure(can_put_unit(unit, to), "Cannot relocate, destination is blocked: %s" % to):
		return

	for c in occupied_cells_of(unit):    # _units_at을 바꾸기 전에 부른다
		_units.erase(c)
	for c in unit.size.footprint_at(to):
		_units.set(c, unit)
	_units_at.set(unit, to)


## 여러 칸 유닛도 한 번씩만
func all_units() -> Array[Unit]:
	var out: Array[Unit] = []
	out.assign(_units_at.keys())
	return out


# ── private func ─────────────────────────────

## 조건이 거짓이면 기록을 남긴다. 개발 중에는 assert로 멈춘다.
## 배포판에서는 assert가 사라지고 기록만 남는다.
## assert(false, ...)로 쓰면 "항상 거짓" 경고가 나서 조건을 변수로 받는다
func _ensure(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
	assert(ok, message)
	return ok
