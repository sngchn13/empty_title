@abstract
class_name GridConst
extends RefCounted

enum Facing { NORTH, EAST, SOUTH, WEST }

static func parse_facing(facing_name: String) -> Facing:
	if not Facing.has(facing_name):
		push_error("Unknown facing: %s" % facing_name)
		return Facing.NORTH
	return Facing[facing_name]
