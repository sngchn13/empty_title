@abstract
class_name JsonValue
extends RefCounted


static func from_vector3i(v: Vector3i) -> Array:
	return [v.x, v.y, v.z]


## JSON에서는 숫자가 float로 돌아오므로 int로 바꾼다
static func to_vector3i(a: Array) -> Vector3i:
	return Vector3i(int(a[0]), int(a[1]), int(a[2]))
