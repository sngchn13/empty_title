extends Node

const CHUNK_PATH := "res://test/chunk_4x4.json"
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var _passed := 0
var _failed := 0


func _ready() -> void:
	# 허용 목록을 먼저 만든다. 컴포넌트에 문제가 있으면 여기서 바로 오류가 뜬다
	ComponentCodec.warm_up()

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not parsed is Dictionary:
		print_rich("[color=red]Cannot read %s[/color]" % CHUNK_PATH)
		return
	var source: Dictionary = parsed

	var chunk := Chunk.new()
	chunk.load_save(source)

	print_rich("[b]=== Chunk tests ===[/b]")
	_test_round_trip(chunk, source)
	_test_place_twice(chunk)
	_print_summary()


# ── 테스트 ──────────────────────────────

## 청크 → 저장소 → 세이브가 청크와 같은 내용인가
func _test_round_trip(chunk: Chunk, source: Dictionary) -> void:
	_section("1. round trip: chunk → repository → save")
	var repo := EntityRepository.new()
	var ids := TestChunkPlacer.new(repo).place(chunk, Vector3i.ZERO)
	_draw_tiles(repo)

	_check(ids.size() == 16, "16 entities placed", "got %d" % ids.size())
	_check(repo.query([GridPosition, TileType]).size() == 16,
		"every entity has GridPosition + TileType")

	# 세이브에서 id를 빼고 컴포넌트만 꺼내 청크와 같은 모양으로 만든다
	var saved: Array = []
	for entry: Dictionary in repo.to_save()["entities"]:
		saved.append(entry["components"])

	var expected: Array = _normalize(source["entities"])
	var actual: Array = _normalize(saved)
	var diff := _first_difference(expected, actual)
	_check(diff.is_empty(), "save matches chunk", diff)


## 같은 청크를 두 번 놓아도 컴포넌트를 공유하지 않는가
func _test_place_twice(chunk: Chunk) -> void:
	_section("2. place twice: offset (0, 0, 0) and (4, 0, 0)")
	var repo := EntityRepository.new()
	var placer := TestChunkPlacer.new(repo)
	var first := placer.place(chunk, Vector3i(0, 0, 0))
	var second := placer.place(chunk, Vector3i(4, 0, 0))
	_draw_tiles(repo)

	var count := repo.query([GridPosition]).size()
	_check(count == 32, "32 entities (got %d)" % count)

	var a := repo.get_component(first[0], GridPosition) as GridPosition
	var b := repo.get_component(second[0], GridPosition) as GridPosition
	_check(a != b,
		"components not shared (#%d vs #%d)" % [a.get_instance_id(), b.get_instance_id()])
	_check(b.get_value() == Vector3i(4, 0, 0),
		"offset applied (second[0] at %s)" % b.get_value())


# ── 그리기 ──────────────────────────────

## 저장소의 타일을 위에서 내려다본 격자로 그린다. 층(y)마다 하나씩
func _draw_tiles(repo: EntityRepository) -> void:
	var tile_at: Dictionary[Vector3i, String] = {}
	for id in repo.query([GridPosition, TileType]):
		var cell := (repo.get_component(id, GridPosition) as GridPosition).get_value()
		var tile := (repo.get_component(id, TileType) as TileType).get_value()
		tile_at[cell] = String(tile)

	if tile_at.is_empty():
		print("    (no tiles)")
		return

	# 칸이 있는 범위
	var low: Vector3i = tile_at.keys()[0]
	var high := low
	for cell: Vector3i in tile_at:
		low = low.min(cell)
		high = high.max(cell)

	# 지형 id → 글자 한 개
	var legend := _make_legend(tile_at.values())
	var parts := PackedStringArray()
	for tile in legend:
		parts.append("%s=%s" % [legend[tile], tile])
	print("    legend: " + "  ".join(parts))

	for y in range(low.y, high.y + 1):
		print("    y=%d" % y)
		var header := "        "
		for x in range(low.x, high.x + 1):
			header += "x%-2d" % x
		print(header)
		for z in range(low.z, high.z + 1):
			var row := "    z%-2d " % z
			for x in range(low.x, high.x + 1):
				var tile: String = tile_at.get(Vector3i(x, y, z), "")
				row += "%-3s" % legend.get(tile, ".")    # 타일이 없는 칸은 점
			print(row)


## 지형 id를 이름순으로 정렬해서 A, B, C … 를 붙인다
func _make_legend(tiles: Array) -> Dictionary[String, String]:
	var names: Array[String] = []
	for tile: String in tiles:
		if not names.has(tile):
			names.append(tile)
	names.sort()

	var out: Dictionary[String, String] = {}
	for i in names.size():
		out[names[i]] = LETTERS[i % LETTERS.length()]
	return out


# ── 결과 출력 ───────────────────────────

func _section(title: String) -> void:
	print_rich("\n[b]%s[/b]" % title)


## 통과하면 초록 ✓, 실패하면 빨간 ✗와 자세한 내용을 찍는다.
## assert로 멈추지 않으니 실패해도 나머지 검사가 계속 돈다
func _check(ok: bool, label: String, detail: String = "") -> void:
	if ok:
		_passed += 1
		print_rich("    [color=green]✓[/color] %s" % label)
		return

	_failed += 1
	print_rich("    [color=red]✗ %s[/color]" % label)
	if not detail.is_empty():
		print("        " + detail.replace("\n", "\n        "))
	push_error("Test failed: %s" % label)


func _print_summary() -> void:
	var color := "green" if _failed == 0 else "red"
	print_rich("\n[color=%s][b]%d passed, %d failed[/b][/color]" % [color, _passed, _failed])


# ── 도우미 ──────────────────────────────

## 처음으로 다른 개체를 찾아 설명을 돌려준다. 같으면 빈 문자열
func _first_difference(expected: Array, actual: Array) -> String:
	if expected.size() != actual.size():
		return "entity count: expected %d, actual %d" % [expected.size(), actual.size()]
	for i in expected.size():
		if expected[i] != actual[i]:
			return "entity %d\nexpected: %s\nactual:   %s" % [i, expected[i], actual[i]]
	return ""


## JSON을 한 번 거쳐서 숫자 타입(int/float)을 맞춘다
func _normalize(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))
