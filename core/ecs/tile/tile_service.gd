class_name TileService
extends Service

## newtype 패턴쓰기
func new_tile(cell: Vector3i, tile_type: StringName) -> void:
	var entity = _repository.create()
	_set_tile(entity, cell, tile_type)


func _set_tile(entity: int, cell: Vector3i, tile_type: StringName ) -> void:
	_repository.set_component(entity, GridPosition.new(cell))
	_repository.set_component(entity, TileType.new(tile_type))
