## EntityIndex와 여러 클래스를 사용하여 논리적인 게임을 구성하는 존재
class_name BoardManager
extends RefCounted

var _map_seed: int
var _entity_index: EntityIndex

func _init() -> void:
	_map_seed = 0 # 나중에 시드 생성기 만들고 바꾸기
	_entity_index = EntityIndex.new()	
