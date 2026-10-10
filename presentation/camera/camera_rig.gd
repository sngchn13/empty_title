## 카메라 리그. 위치는 바라보는 바닥의 한 점, Y 회전은 바라보는 방향.
## 카메라는 자식으로 붙어서 이 점을 내려다본다
class_name CameraRig
extends Node3D

@export var move_speed := 8.0          ## 초당 이동 거리(m)
@export var rotate_step := 90.0        ## Q/E 한 번에 도는 각도(도)
@export var rotate_time := 0.2         ## 한 번 도는 데 걸리는 시간(초)

var _rotate_tween: Tween


func _process(delta: float) -> void:
	var input := Input.get_vector(
		&"camera_left", &"camera_right", &"camera_forward", &"camera_back")
	if input == Vector2.ZERO:
		return
	# 리그가 보는 방향 기준으로 바닥 위에서 움직인다. 리그는 Y 회전만 있어서 높이가 섞이지 않는다
	position += basis * Vector3(input.x, 0, input.y) * move_speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_rotate_left"):
		_rotate_by(rotate_step)
	elif event.is_action_pressed(&"camera_rotate_right"):
		_rotate_by(-rotate_step)


func _rotate_by(degrees: float) -> void:
	if _rotate_tween != null and _rotate_tween.is_running():
		return    # 도는 중에 또 누르면 무시한다. 각도가 90도 단위에서 어긋나지 않게
	_rotate_tween = create_tween()
	_rotate_tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(degrees), rotate_time)
