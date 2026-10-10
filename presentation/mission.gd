class_name Mission
extends Node

@onready var board_view: BoardView = $BoardView
var _container: ServiceContainer = ServiceContainer.new()

func _ready() -> void:
	board_view.setup(_container)
