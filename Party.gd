extends Node2D

# Сигналы
signal reached_point(point_id)  # Достигнута точка маршрута
signal movement_completed       # Движение завершено

# Экспортируемые параметры
@export var speed: float = 200.0  # Скорость движения

# Переменные для движения
var path: Array[Vector2] = []      # Точки пути
var path_ids: Array[int] = []      # ID точек пути
var current_point_index: int = 0   # Текущая точка в пути
var target_position: Vector2       # Целевая позиция
var is_moving: bool = false        # Флаг движения

func _ready() -> void:
	# Инициализация начального состояния
	target_position = position

func _process(delta: float) -> void:
	if not is_moving:
		return
	
	# Движение к текущей цели
	var direction = target_position - position
	var distance = direction.length()
	
	if distance > 1.0:
		# Плавное движение к цели
		var movement = direction.normalized() * speed * delta
		if movement.length() > distance:
			position = target_position
		else:
			position += movement
	else:
		# Достигли текущей точки
		position = target_position
		
		# Проверяем, есть ли следующая точка
		if current_point_index < path.size():
			# Сообщаем о достижении точки
			emit_signal("reached_point", path_ids[current_point_index])
			
			# Переходим к следующей точке
			current_point_index += 1
			if current_point_index < path.size():
				target_position = path[current_point_index]
			else:
				# Путь завершен
				is_moving = false
				emit_signal("movement_completed")

func set_path(new_path: Array[Vector2], new_path_ids: Array[int]) -> void:
	"""Устанавливает новый путь движения"""
	if new_path.is_empty():
		return
	
	path = new_path
	path_ids = new_path_ids
	current_point_index = 0
	target_position = path[0]
	is_moving = true

func get_current_position() -> Vector2:
	"""Возвращает текущую позицию отряда"""
	return position