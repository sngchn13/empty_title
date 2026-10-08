## 컴포넌트 ↔ 저장 데이터(Dictionary). 세이브와 청크가 같이 쓴다.
##
## 개체 하나의 저장 데이터 모양:
##   { "컴포넌트 클래스 이름": 그 컴포넌트의 to_save() 결과, ... }
##
## 이름으로 클래스를 찾을 때는 Component를 상속한 클래스만 받는다 (허용 목록).
## 허용 목록은 실행 중에 바뀌지 않으므로 상태가 없다고 보고 전역 static으로 둔다.
@abstract
class_name ComponentCodec
extends RefCounted

## 클래스 이름 → 클래스. Component를 상속한 것만 들어 있다. 처음 쓸 때 한 번 만든다
static var _types: Dictionary[StringName, GDScript] = {}


## 허용 목록을 만든다. 이미 만들었으면 아무것도 안 한다.
## 게임을 시작할 때 한 번 불러 두면 _init 기본값 누락 같은 문제를 시작하자마자 알 수 있다
static func warm_up() -> void:
	if _types.is_empty():
		_types = _find_component_types()


# ── 컴포넌트 → 저장 데이터 ─────────────

static func type_name_of(component: Component) -> StringName:
	var mold: Script = component.get_script()
	return mold.get_global_name()


## 개체 하나의 컴포넌트들을 저장 데이터로 바꾼다.
## 키를 String으로 두어 JSON에서 읽어 온 데이터와 같은 모양이 되게 한다
static func encode(components: Array[Component]) -> Dictionary:
	var out := {}
	for component in components:
		out[String(type_name_of(component))] = component.to_save()
	return out


# ── 저장 데이터 → 컴포넌트 ─────────────

## 이름으로 빈 컴포넌트를 만든다. 허용 목록에 없으면 null.
## 컴포넌트의 _init 매개변수에 기본값이 없으면 여기서 실패한다
static func create(type_name: StringName) -> Component:
	warm_up()
	var mold: GDScript = _types.get(type_name)
	if mold == null:
		push_error("Unknown component type: %s" % type_name)
		return null
	return mold.new() as Component


## 개체 하나의 저장 데이터를 컴포넌트들로 바꾼다.
## 부를 때마다 새 객체를 만든다. 같은 데이터를 두 번 넣어도 객체를 공유하지 않는다
static func decode(data: Dictionary) -> Array[Component]:
	var out: Array[Component] = []
	for type_name: String in data:
		var component := create(StringName(type_name))
		if component == null:
			continue
		component.load_save(data[type_name])
		out.append(component)
	return out


# ── 허용 목록 ─────────────────────────

## class_name이 붙은 클래스 중 Component를 상속한 것을 전부 모은다
static func _find_component_types() -> Dictionary[StringName, GDScript]:
	var base_of: Dictionary[StringName, StringName] = {}
	var path_of: Dictionary[StringName, String] = {}
	for info in ProjectSettings.get_global_class_list():
		base_of[info["class"]] = info["base"]
		path_of[info["class"]] = info["path"]

	var out: Dictionary[StringName, GDScript] = {}
	for cls: StringName in base_of:
		if _inherits_component(cls, base_of):
			var mold := load(path_of[cls]) as GDScript
			_check_init_defaults(cls, mold)
			out[cls] = mold
	return out


## _init의 매개변수에 전부 기본값이 있는지 본다.
## 없으면 불러올 때 new()가 실패하므로 미리 알려 준다
static func _check_init_defaults(cls: StringName, mold: GDScript) -> void:
	for method in mold.get_script_method_list():
		if method["name"] != "_init":
			continue
		var args: Array = method["args"]
		var defaults: Array = method["default_args"]
		if args.size() > defaults.size():
			push_error("Component %s: every _init parameter needs a default value" % cls)


## 부모를 따라 올라가며 Component가 나오는지 본다. 손자 클래스도 찾는다
static func _inherits_component(
	cls: StringName,
	base_of: Dictionary[StringName, StringName],
) -> bool:
	var current: StringName = base_of.get(cls, &"")
	while current != &"":
		if current == &"Component":
			return true
		current = base_of.get(current, &"")
	return false
