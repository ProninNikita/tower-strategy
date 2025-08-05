# Структура узла карты
extends Node

var id: int
var position: Vector2
var event_type: int
var connections: Array[int] = []  # ID узлов, к которым есть связь
var visited: bool = false
var is_current: bool = false 