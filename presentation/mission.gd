class_name Mission
extends Node

@onready var board_view: BoardView = $BoardView
var _container: ServiceContainer = ServiceContainer.new()

func _ready() -> void:
	
	#todo 밑에 2줄삭제
	var ms := _container.get_service(MapService) as MapService
	ms.place_test_chunk()
	
	board_view.setup(_container)
