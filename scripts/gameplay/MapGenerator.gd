extends Node

# Константы для генерации карты
const SPACING_Y = -150  # Расстояние между точками по вертикали
const SPACING_X = 200   # Расстояние между ветками по горизонтали

# Подключаем необходимые классы
const MapPointDataClass = preload("res://scripts/data/map_point_data.gd")
const Constants = preload("res://scripts/data/map_constants.gd")

# Переменные для управления картой
var points: Array = []  # Все точки карты
var next_point_id: int = 0            # Следующий ID точки
var current_point_id: int = -1        # Текущая точка (где находится отряд)

# Вероятности событий (в процентах)
var event_probabilities = {
	"BATTLE": 40,
	"SHOP": 20,
	"RANDOM": 20,
	"EMPTY": 20
}

func _ready() -> void:
	# Инициализация генератора случайных чисел
	randomize()

func generate_initial_segment() -> Array:
	"""Генерирует начальный сегмент карты с Safe Zone и развилками"""
	points.clear()
	next_point_id = 0
	
	# Создаем Safe Zone внизу карты
	var start_pos = Vector2(600, 700)
	var safe_point = MapPointDataClass.new(next_point_id, start_pos, Constants.EventType.SAFE)
	points.append(safe_point)
	next_point_id += 1
	
	# Генерируем стартовый сегмент с развилками
	generate_starting_segment(safe_point)
	
	return points

func generate_starting_segment(from_point) -> void:
	"""Генерирует стартовый сегмент с развилками"""
	print("MapGenerator: Генерируем стартовый сегмент от Safe Zone")
	
	# Создаем только одну точку в основной линии
	var start_pos = from_point.position + Vector2(0, SPACING_Y)
	var current_point = from_point
	
	# Генерируем только одну точку в основной линии
	var new_pos = start_pos
	
	# Проверяем, что позиция не занята
	while is_position_occupied(new_pos):
		new_pos += Vector2(0, SPACING_Y)
		print("MapGenerator: Позиция занята, смещаем на ", new_pos)
	
	var event_type = get_random_event_type()
	var is_branch = true  # Эта точка - точка ветвления
	
	var new_point = MapPointDataClass.new(next_point_id, new_pos, event_type, is_branch)
	points.append(new_point)
	
	# Создаем связь с Safe Zone
	current_point.connections.append(new_point.id)
	new_point.connections.append(current_point.id)
	print("MapGenerator: Связываем Safe Zone с точкой ", new_point.id)
	
	next_point_id += 1
	current_point = new_point
	
	# Создаем развилки от этой точки
	var branch_count = randi_range(1, 2)  # От 1 до 2 развилок
	print("MapGenerator: Создаем ", branch_count, " развилок от точки ", current_point.id)
	generate_starting_branches(current_point, branch_count)

func generate_starting_branches(from_point, count: int) -> void:
	"""Генерирует развилки для стартового сегмента"""
	for i in range(count):
		# Вычисляем позицию ветки (смещение по горизонтали)
		var offset = (i - (count - 1) / 2.0) * SPACING_X
		var branch_pos = from_point.position + Vector2(offset, SPACING_Y)
		
		# Проверяем, что позиция не занята
		while is_position_occupied(branch_pos):
			branch_pos += Vector2(0, SPACING_Y)
			print("MapGenerator: Позиция ветки занята, смещаем на ", branch_pos)
		
		# Создаем точку ветвления
		var event_type = get_random_event_type()
		var branch_point = MapPointDataClass.new(next_point_id, branch_pos, event_type)
		points.append(branch_point)
		
		# Создаем связь с точкой ветвления
		from_point.connections.append(branch_point.id)
		branch_point.connections.append(from_point.id)
		print("MapGenerator: Создаем развилку от точки ", from_point.id, " к точке ", branch_point.id)
		
		next_point_id += 1

func generate_segment(from_point, _length: int = 1, _branches: int = 1) -> void:
	"""Генерирует новый сегмент карты от указанной точки"""
	print("MapGenerator: Генерируем новый сегмент от точки ", from_point.id)
	
	# Создаем только одну точку вперед
	var new_pos = from_point.position + Vector2(0, SPACING_Y)
	
	# Проверяем, что позиция не занята существующей точкой
	while is_position_occupied(new_pos):
		new_pos += Vector2(0, SPACING_Y)
		print("MapGenerator: Позиция занята, смещаем на ", new_pos)
	
	var event_type = get_random_event_type()
	var is_branch = true  # Эта точка - точка ветвления
	
	var new_point = MapPointDataClass.new(next_point_id, new_pos, event_type, is_branch)
	points.append(new_point)
	
	# Создаем связь с исходной точкой
	from_point.connections.append(new_point.id)
	new_point.connections.append(from_point.id)
	print("MapGenerator: Связываем точку ", from_point.id, " с новой точкой ", new_point.id)
	
	next_point_id += 1
	
	# Создаем развилки от новой точки
	var branch_count = randi_range(1, 2)  # От 1 до 2 развилок
	print("MapGenerator: Создаем ", branch_count, " развилок от точки ", new_point.id)
	generate_branches(new_point, branch_count)
	
	print("MapGenerator: Сегмент сгенерирован. Всего точек: ", points.size())

func generate_branches(from_point, _count: int) -> void:
	"""Генерирует ответвления от указанной точки"""
	# Создаем только одну ветку по центру
	var branch_pos = from_point.position + Vector2(0, SPACING_Y)
	
	# Проверяем, что позиция не занята существующей точкой
	while is_position_occupied(branch_pos):
		branch_pos += Vector2(0, SPACING_Y)
		print("MapGenerator: Позиция ветки занята, смещаем на ", branch_pos)
	
	# Создаем точку ветвления
	var event_type = get_random_event_type()
	var branch_point = MapPointDataClass.new(next_point_id, branch_pos, event_type)
	points.append(branch_point)
	
	# Ветка ищет ближайшие к себе точки и связывается с ними
	connect_to_nearest_points(branch_point)
	
	next_point_id += 1

func get_random_event_type() -> int:
	"""Возвращает случайный тип события на основе вероятностей"""
	var total = 0
	for probability in event_probabilities.values():
		total += probability
	
	var roll = randi() % total
	var current_total = 0
	
	for event_name in event_probabilities:
		current_total += event_probabilities[event_name]
		if roll < current_total:
			return Constants.EventType[event_name]
	
	return Constants.EventType.EMPTY

func get_point_by_id(id: int):
	"""Возвращает точку по ID"""
	for point in points:
		if point.id == id:
			return point
	return null

func get_connected_points(point_id: int) -> Array[int]:
	"""Возвращает ID всех точек, связанных с указанной"""
	var point = get_point_by_id(point_id)
	if point:
		return point.connections
	return []

func set_current_point(point_id: int) -> void:
	"""Устанавливает текущую точку"""
	current_point_id = point_id

func is_position_occupied(pos: Vector2) -> bool:
	"""Проверяет, занята ли позиция существующей точкой"""
	for point in points:
		if point.position.distance_to(pos) < 50:  # Минимальное расстояние между точками
			return true
	return false

func connect_to_nearest_points(new_point) -> void:
	"""Новая точка ищет ближайшие к себе точки и связывается с ними"""
	var nearest_points: Array = []
	var max_connections = 2  # Максимальное количество связей для новой точки
	
	# Ищем все точки, которые находятся в пределах разумного расстояния
	for point in points:
		if point.id == new_point.id:
			continue  # Пропускаем саму точку
		
		var distance = new_point.position.distance_to(point.position)
		if distance <= SPACING_Y * 2:  # Увеличиваем радиус поиска
			nearest_points.append(point)
	
	# Если не нашли точек в радиусе, ищем любую ближайшую
	if nearest_points.is_empty():
		for point in points:
			if point.id != new_point.id:
				nearest_points.append(point)
	
	# Сортируем по расстоянию (ближайшие первые)
	nearest_points.sort_custom(func(a, b): return new_point.position.distance_to(a.position) < new_point.position.distance_to(b.position))
	
	# Связываемся с ближайшими точками (но не более max_connections)
	var connections_made = 0
	for point in nearest_points:
		if connections_made >= max_connections:
			break
		
		# Проверяем, что связь еще не существует
		if not new_point.connections.has(point.id):
			# Создаем двустороннюю связь
			new_point.connections.append(point.id)
			point.connections.append(new_point.id)
			print("MapGenerator: Новая точка ", new_point.id, " связывается с ближайшей точкой ", point.id, " (расстояние: ", new_point.position.distance_to(point.position), ")")
			connections_made += 1
	
	if connections_made == 0:
		print("MapGenerator: ОШИБКА: точка ", new_point.id, " не смогла создать ни одной связи!")
	else:
		print("MapGenerator: Точка ", new_point.id, " создала ", connections_made, " связей")
