class_name GridPosition
extends Component

var _cell: Vector3i

func _init(cell: Vector3i = Vector3i.ZERO) -> void:
	_cell = cell

func get_value() -> Vector3i:
	return self._cell

func to_save() -> Dictionary:
	return { "_cell": [_cell.x, _cell.y, _cell.z] }
	
func load_save(data: Dictionary) -> void:
	var cell: Array = data["_cell"]
	_cell = Vector3i(cell[0], cell[1], cell[2])
