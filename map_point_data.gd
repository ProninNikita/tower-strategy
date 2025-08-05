class_name MapPointData
extends RefCounted

var id: int
var position: Vector2
var event_type: int
var is_branch_point: bool
var connections: Array[int]

func _init(p_id: int, pos: Vector2, type: int, is_branch: bool = false):
	id = p_id
	position = pos
	event_type = type
	is_branch_point = is_branch
	connections = []