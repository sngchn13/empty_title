class_name TileSpec
extends RefCounted

var id: int
var tile_type: StringName
var cell: Vector3i

func _init(new_id: int, new_tile_type: StringName, new_cell: Vector3i) -> void:
	id = new_id
	tile_type = new_tile_type
	cell = new_cell
