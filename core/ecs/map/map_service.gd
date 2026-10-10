## 맵을 만든다
class_name MapService
extends Service

const TEST_CHUNK_PATH := "res://test/chunk_4x4.json"


## 테스트용: 청크 파일 하나를 읽어 저장소에 그대로 놓는다
func place_test_chunk() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_CHUNK_PATH))
	if not parsed is Dictionary:
		push_error("Cannot read chunk: %s" % TEST_CHUNK_PATH)
		return

	var chunk := Chunk.new()
	chunk.load_save(parsed)

	for entity_data in chunk.entities:
		var id := _repository.create()
		for component in ComponentCodec.decode(entity_data):
			_repository.set_component(id, component)
