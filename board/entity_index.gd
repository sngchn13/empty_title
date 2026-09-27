## Entity들의 위치 정보를 기록한 것
class_name EntityIndex
extends RefCounted

var _tiles: Dictionary[Vector3i, Tile] = {}

var _units: Dictionary[Vector3i, Unit] = {}
var _units_at: Dictionary[Unit, Vector3i] = {}

var _occupants: Dictionary[Vector3i, Array] = {}
var _occupants_at: Dictionary[Occupant, Vector3i] = {}

## get, take, remove 필요
