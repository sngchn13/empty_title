## 모든 컴포넌트는 이 클래스를 상속해야함
@abstract
class_name Component
extends RefCounted

## _init에 기본값 필수!!

@abstract func to_save() -> Dictionary
@abstract func load_save(data: Dictionary) -> void 
