##관련된 TerrainType들을 모아둬서 MapGenerator가 맵생성시 활용할 수 있도록 하는 클래스
class_name TerrainSet
extends Resource

@export var terrain_list: Array[TerrainType] = []
