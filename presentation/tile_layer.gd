class_name TileLayer
extends GridMap

var _tile_service: TileService
@export var meshlib: MeshLibrary

func _ready() -> void:
	pass

func setup(tile_service: TileService) -> void:
	_tile_service = tile_service
