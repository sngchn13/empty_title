class_name TileLayer
extends GridMap

var _tile_service: TileService

func _ready() -> void:
	pass

func setup(tile_service: TileService) -> void:
	_tile_service = tile_service
	_set_tile()
	
	
func _set_tile() -> void:
	var tiles: Array[TileSpec] = _tile_service.get_all_tiles()
	
	for tile in tiles:
		self.set_cell_item(tile.cell,mesh_library.find_item_by_name(tile.tile_type.to_pascal_case()))
