class_name BoardView
extends Node3D

@onready var _tile_layer: TileLayer = $TileLayer

func _ready() -> void:
	pass
	
func setup(container: ServiceContainer) -> void:
	_tile_layer.setup(container.get_service(TileService) as TileService)
