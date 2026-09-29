## Entity들의 위치 정보를 기록한 것
class_name EntityIndex
extends RefCounted

var _tiles: Dictionary[Vector3i, Tile] = {}

var _units: Dictionary[Vector3i, Unit] = {}
var _units_at: Dictionary[Unit, Vector3i] = {}

###occupants로 하면 안됨. unit이 occupants를 상속해서 occupants에 들어갈 수 있음. prop이런걸로 만들어야 함.
#var _props: Dictionary[Vector3i, Array] = {}
#var _props_at: Dictionary[Prop, Vector3i] = {}

# put, take, relocate, swap, reorient(방향 바꾸기) 필요

# ── Tile: 칸으로 다룬다 ─────────────────

## 없으면 null
func tile_at(cell: Vector3i) -> Tile:
	return _tiles.get(cell)

#func has_tile(cell: Vector3i) -> bool:
#
### 빈 칸에만 넣는다. 이미 있으면 assert
#func put_tile(tile: Tile, cell: Vector3i) -> void:
#
### 뺀 타일을 돌려준다. 없으면 null
#func take_tile(cell: Vector3i) -> Tile:
#
### 원래 타일을 돌려준다. 없었으면 null
#func swap_tile(tile: Tile, cell: Vector3i) -> Tile:
#
### keys()는 타입 없는 배열이라 assign으로 옮긴다
#func all_tile_cells() -> Array[Vector3i]:
#
#
## ── Unit: 객체로 다룬다 ─────────────────
#
### 다중 칸 유닛은 어느 칸을 물어도 같은 유닛. 없으면 null
#func unit_at(cell: Vector3i) -> Unit:
#
#func has_unit_at(cell: Vector3i) -> bool:
#
#func is_unit_placed(unit: Unit) -> bool:
#
### 기준 칸. 보드에 없는 유닛이면 assert (Vector3i는 null이 될 수 없다)
#func cell_of(unit: Unit) -> Vector3i:
#
### 차지하는 칸 전부. 보드에 없으면 빈 배열
#func cells_of(unit: Unit) -> Array[Vector3i]:
#
### 이미 보드에 있는 유닛이면 assert
### 차지할 칸을 전부 검사한 다음에 기록한다
#func put_unit(unit: Unit, cell: Vector3i) -> void:
#
### 보드에 없으면 아무것도 안 한다
### 차지하던 칸을 전부 지운다
#func take_unit(unit: Unit) -> void:
#
### 자기 칸을 먼저 비운 다음 새 칸을 검사한다
### cells_of는 _units_at을 바꾸기 전에 부른다
### _units_at은 키를 지우지 말고 값만 바꾼다 (순서 유지)
#func relocate_unit(unit: Unit, to: Vector3i) -> void:
#
### 여러 칸 유닛도 한 번씩만
#func all_units() -> Array[Unit]:
