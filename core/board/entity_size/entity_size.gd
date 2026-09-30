## 엔티티가 차지하는 공간.
class_name EntitySize
extends Resource

## 가로세로 칸 수. 1이면 1×1, 2면 2×2.
@export_range(1, 4) var side: int = 1
## 몇 층 높이인가. 머리 위 공간 판정에 쓴다.
@export_range(1, 4) var height: int = 1

## 기준점은 x, z가 가장 작은 모서리 칸이다.
func footprint_at(origin: Vector3i) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for dx in side:
		for dz in side:
			out.append(origin + Vector3i(dx, 0, dz))
	return out
