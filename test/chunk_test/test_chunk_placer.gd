## 테스트용 청크 플레이서. 회전 없이 offset만 더한다.
## 회전과 2×2 기준점 처리가 들어간 ChunkPlacer를 만들면 지운다
class_name TestChunkPlacer
extends Service


## 청크를 offset 위치에 놓는다. 만든 개체의 id를 청크 순서대로 돌려준다
func place(chunk: Chunk, offset: Vector3i) -> Array[int]:
	var ids: Array[int] = []
	for entity_data in chunk.entities:
		var id := _repository.create()
		for component in ComponentCodec.decode(entity_data):
			_repository.set_component(id, _moved(component, offset))
		ids.append(id)
	return ids


## GridPosition이면 offset만큼 옮긴 새 컴포넌트를, 아니면 그대로 돌려준다.
## GridPosition은 고치지 않고 새로 만든다
func _moved(component: Component, offset: Vector3i) -> Component:
	var pos := component as GridPosition
	if pos == null:
		return component
	return GridPosition.new(pos.get_value() + offset)
