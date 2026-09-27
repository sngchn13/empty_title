## EntityIndex와 여러 클래스를 사용하여 논리적인 게임을 구성하는 존재
class_name BoardManager
extends RefCounted

#var _bounds: Vector3i ##맵의 경계
var _map_seed: int

#var _tiles: Dictionary[Vector3i, Tile] = {}
#var _units: Dictionary[Vector3i, Unit] = {}
#var _occupants: Dictionary[Vector3i, Array] = {}
#
#func _init(bounds: Vector3i, map_seed: int) -> void:
	#_bounds = bounds
	#_map_seed = map_seed
	#
#
#func add(entity: Entity, cell: Vector3i) -> void:
	#if entity is Tile:
		#_tiles[cell] = entity as Tile
	#elif entity is Unit:
		#_units[cell] = entity as Unit
	#else:
		#if not _occupants.has(cell):
			#var arr: Array[Entity] = []
			#_occupants[cell] = arr
		#_occupants[cell].append(entity)
		#
#func remove_tile(cell: Vector3i) -> void:
	#pass
	#
#func move(entity: Entity, cell: Vector3i) -> void:
	#pass
#
#func _remove_all_occupants(cell: Vector3i) -> void:
	#_occupants.erase(cell)
