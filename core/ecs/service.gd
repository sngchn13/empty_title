@abstract
class_name Service
extends RefCounted

var _repository: EntityRepository

func _init(repository: EntityRepository) -> void:
	assert(repository != null, "Service needs an EntityRepository")
	_repository = repository
