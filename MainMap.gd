extends Node2D

# Узлы
@onready var map_generator: Node = $MapGenerator
@onready var party: Node2D = $Party
@onready var camera: Camera2D = $Camera2D
@onready var path_line: Line2D = $PathLine

# Настройки
const CAMERA_OFFSET = Vector2(0, -200)  # Смещение камеры вверх
const PATH_WIDTH = 4.0                  # Толщина линии пути
const PATH_COLOR = Color(0.7, 0.7, 0.7, 0.5)  # Цвет линии пути
const SPACING_Y = -150  # Расстояние между точками по вертикали (должно совпадать с MapGenerator)

# Переменные состояния
var point_nodes: Dictionary = {}  # Словарь узлов точек (id: node)
var selected_path: Array[int] = []  # ID точек выбранного пути
var is_moving: bool = false  # Флаг движения отряда

func _ready() -> void:
	print("MainMap: _ready() вызван")
	
	# Инициализация карты
	initialize_map()
	
	# Подключаем сигналы отряда
	party.reached_point.connect(_on_party_reached_point)
	party.movement_completed.connect(_on_party_movement_completed)
	
	print("MainMap: _ready() завершен")

func initialize_map() -> void:
	"""Инициализирует начальную карту"""
	print("MainMap: Начинаем инициализацию карты")
	
	# Генерируем начальный сегмент
	var points = map_generator.generate_initial_segment()
	print("MainMap: Сгенерировано точек: ", points.size())
	
	# Создаем узлы для всех точек
	for point_data in points:
		create_point_node(point_data)
	
	print("MainMap: Создано узлов: ", point_nodes.size())
	
	# Принудительно создаем связи для начального сегмента
	create_initial_connections()
	
	# Показываем все связи для отладки
	debug_print_all_connections()
	
	# Обновляем линии пути
	update_path_lines()
	
	# Устанавливаем начальную позицию отряда
	if points.size() > 0:
		party.position = points[0].position
		map_generator.set_current_point(points[0].id)
		print("MainMap: Отряд размещен на позиции: ", points[0].position)
	
	# Настраиваем камеру
	setup_camera()
	print("MainMap: Инициализация карты завершена")

func create_initial_connections() -> void:
	"""Принудительно создает связи для начального сегмента"""
	print("MainMap: Создаем связи для начального сегмента")
	
	# Создаем связи между всеми точками в радиусе (не очищаем существующие)
	for i in range(map_generator.points.size()):
		var current_point = map_generator.points[i]
		
		# Ищем все точки в радиусе
		for j in range(map_generator.points.size()):
			if i == j:
				continue
			
			var other_point = map_generator.points[j]
			var distance = current_point.position.distance_to(other_point.position)
			
			# Если точки близко и еще не связаны, создаем двустороннюю связь
			if distance <= abs(SPACING_Y) * 2.0:  # Увеличиваем радиус
				if not current_point.connections.has(other_point.id):
					current_point.connections.append(other_point.id)
					print("MainMap: Добавляем связь: точка ", current_point.id, " -> ", other_point.id, " (расстояние: ", distance, ")")
				
				# Создаем обратную связь
				if not other_point.connections.has(current_point.id):
					other_point.connections.append(current_point.id)
					print("MainMap: Добавляем обратную связь: точка ", other_point.id, " -> ", current_point.id)
	
	# Проверяем, что все точки имеют хотя бы одну связь
	for point_data in map_generator.points:
		if point_data.connections.is_empty():
			print("MainMap: ВНИМАНИЕ! Точка ", point_data.id, " не имеет связей!")
		else:
			print("MainMap: Точка ", point_data.id, " имеет ", point_data.connections.size(), " связей: ", point_data.connections)

func create_point_node(point_data) -> void:
	"""Создает узел точки карты"""
	print("MainMap: Создаем узел для точки ", point_data.id, " на позиции ", point_data.position)
	
	# Загружаем сцену точки
	var point_scene = preload("res://MapPoint.tscn")
	var point_node = point_scene.instantiate()
	
	# Настраиваем позицию и свойства
	point_node.position = point_data.position
	point_node.point_id = point_data.id
	point_node.set_event_type(point_data.event_type)
	point_node.is_branch_point = point_data.is_branch_point
	
	# Подключаем сигнал клика
	point_node.point_clicked.connect(_on_point_selected)
	
	# Добавляем в сцену и словарь
	add_child(point_node)
	point_nodes[point_data.id] = point_node
	print("MainMap: Узел точки ", point_data.id, " создан успешно")

func debug_print_all_connections() -> void:
	"""Выводит все связи на карте для отладки"""
	print("MainMap: === ОТЛАДКА ВСЕХ СВЯЗЕЙ ===")
	for point_data in map_generator.points:
		print("MainMap: Точка ", point_data.id, " (", point_data.position, ") -> ", point_data.connections)
	print("MainMap: === КОНЕЦ ОТЛАДКИ ===")

func get_reachable_points() -> Array[int]:
	"""Возвращает список ID всех точек, до которых можно добраться от текущей позиции среди видимых"""
	var reachable: Array[int] = []
	var start_id = map_generator.current_point_id
	var queue: Array[int] = [start_id]
	var visited: Array[int] = []
	
	# Получаем видимые точки
	var current_point_data = map_generator.get_point_by_id(start_id)
	if not current_point_data:
		return reachable
	
	var visible_radius = 2
	var visible_points: Array[int] = []
	for point_data in map_generator.points:
		var distance = current_point_data.position.distance_to(point_data.position)
		if distance <= abs(SPACING_Y) * visible_radius:
			visible_points.append(point_data.id)
	
	# BFS для поиска всех достижимых точек среди видимых
	while not queue.is_empty():
		var current_id = queue.pop_front()
		
		if current_id in visited:
			continue
		
		visited.append(current_id)
		
		# Добавляем только если точка видима
		if current_id in visible_points:
			reachable.append(current_id)
		
		var connections = map_generator.get_connected_points(current_id)
		for next_id in connections:
			if next_id not in visited and next_id not in queue and next_id in visible_points:
				queue.append(next_id)
	
	return reachable

func get_available_points() -> Array[int]:
	"""Возвращает список ID всех доступных точек"""
	var available: Array[int] = []
	for point_data in map_generator.points:
		available.append(point_data.id)
	return available

func _on_point_selected(point: Area2D) -> void:
	"""Обрабатывает выбор точки игроком"""
	print("MainMap: Попытка выбора точки ", point.point_id, ", is_moving = ", is_moving)
	
	# Показываем достижимые точки
	var reachable = get_reachable_points()
	print("MainMap: Достижимые точки от ", map_generator.current_point_id, ": ", reachable)
	
	# Отладочная информация о всех связях - УПРОЩЕНО
	# debug_print_all_connections()
	
	if is_moving:
		print("MainMap: Движение в процессе, игнорируем клик")
		return
	
	# Получаем данные о точке
	var point_data = map_generator.get_point_by_id(point.point_id)
	if not point_data:
		print("MainMap: Данные точки не найдены")
		return
	
	# Проверяем, что точка существует в map_generator
	if not map_generator.points.has(point_data):
		print("MainMap: Точка не найдена в map_generator")
		return
	
	# Показываем анимацию клика
	point.show_click_feedback()
	
	# Строим путь к выбранной точке
	var path = build_path_to_point(point.point_id)
	if path.is_empty():
		print("MainMap: Путь к точке не найден")
		return
	
	# Запоминаем выбранный путь
	selected_path = path
	print("MainMap: Выбран путь: ", selected_path)
	
	# Отключаем клики на время движения
	is_moving = true
	
	# Удаляем ненужные ветки - ОТКЛЮЧЕНО
	# remove_unselected_branches()
	
	# Запускаем движение отряда
	start_party_movement()

func build_path_to_point(target_id: int) -> Array[int]:
	"""Строит путь от текущей точки к целевой используя BFS"""
	print("MainMap: Строим путь от ", map_generator.current_point_id, " к ", target_id)
	
	var start_id = map_generator.current_point_id
	var queue: Array[int] = [start_id]
	var visited: Array[int] = []
	var parent: Dictionary = {}
	
	# BFS для поиска пути
	while not queue.is_empty():
		var current_id = queue.pop_front()
		
		if current_id == target_id:
			# Нашли цель, строим путь обратно
			var path: Array[int] = []
			var current = target_id
			while current != start_id:
				path.push_front(current)
				current = parent[current]
			path.push_front(start_id)
			print("MainMap: Построен путь: ", path)
			print("MainMap: Длина пути: ", path.size(), " точек")
			return path
		
		if current_id in visited:
			continue
		
		visited.append(current_id)
		var connections = map_generator.get_connected_points(current_id)
		# print("MainMap: Точка ", current_id, " имеет связи: ", connections)  # УПРОЩЕНО
		
		for next_id in connections:
			if next_id not in visited and next_id not in queue:
				queue.append(next_id)
				parent[next_id] = current_id
	
	print("MainMap: Путь не найден")
	return []

func start_party_movement() -> void:
	"""Запускает движение отряда по выбранному пути"""
	var path_positions: Array[Vector2] = []
	
	# Собираем позиции точек пути
	for point_id in selected_path:
		var point_data = map_generator.get_point_by_id(point_id)
		if point_data:
			path_positions.append(point_data.position)
	
	# Запускаем движение
	party.set_path(path_positions, selected_path)

func _on_party_reached_point(point_id: int) -> void:
	"""Обрабатывает достижение отрядом точки пути"""
	print("MainMap: Отряд достиг точки ", point_id)
	
	# Обновляем текущую точку
	map_generator.set_current_point(point_id)
	
	# Скрываем старые комнаты, показываем только ближайшие
	update_visible_rooms(point_id)
	
	# Если достигли последней точки в выбранном пути, генерируем новый сегмент
	if point_id == selected_path.back():
		print("MainMap: Достигнут конец пути, генерируем новый сегмент")
		var point_data = map_generator.get_point_by_id(point_id)
		if point_data:
			# Запоминаем количество точек до генерации
			var points_before = map_generator.points.size()
			
			# Генерируем новый сегмент от текущей точки
			map_generator.generate_segment(point_data)
			
			# Создаем узлы только для новых точек (добавленных после генерации)
			for i in range(points_before, map_generator.points.size()):
				var new_point = map_generator.points[i]
				create_point_node(new_point)
				print("MainMap: Создан новый узел для точки ", new_point.id, " на позиции ", new_point.position)
			
			# Обновляем видимость комнат
			update_visible_rooms(point_id)
			
			# Обновляем линии пути
			update_path_lines()
			print("MainMap: Новый сегмент сгенерирован")
		else:
			print("MainMap: Ошибка: не найдены данные точки ", point_id)

func _on_party_movement_completed() -> void:
	"""Обрабатывает завершение движения отряда"""
	print("MainMap: Движение отряда завершено, сбрасываем флаги")
	is_moving = false
	selected_path.clear()
	print("MainMap: is_moving = ", is_moving, ", selected_path пуст = ", selected_path.is_empty())

func remove_unselected_branches() -> void:
	"""Удаляет все ветки, не входящие в выбранный путь"""
	var points_to_remove: Array[int] = []
	
	# Находим точку ветвления (последняя точка в выбранном пути)
	var branch_point_id = selected_path.back()
	var branch_point_data = map_generator.get_point_by_id(branch_point_id)
	
	if branch_point_data:
		print("MainMap: Проверяем ветки от точки ", branch_point_id)
		print("MainMap: Выбранный путь: ", selected_path)
		print("MainMap: Связи точки ветвления: ", branch_point_data.connections)
		
		# Собираем точки для удаления - только те, которые соединены с точкой ветвления
		# но не входят в выбранный путь
		for point_id in point_nodes.keys():
			# Проверяем, что точка соединена с точкой ветвления
			if branch_point_data.connections.has(point_id):
				# НЕ удаляем точки из выбранного пути
				if not point_id in selected_path:
					points_to_remove.append(point_id)
					print("MainMap: Помечаем для удаления ветку ", point_id, " (не в выбранном пути)")
				else:
					print("MainMap: НЕ удаляем точку ", point_id, " (в выбранном пути)")
	
	print("MainMap: Всего точек для удаления: ", points_to_remove.size())
	
	# Удаляем точки
	for point_id in points_to_remove:
		if point_nodes.has(point_id):
			point_nodes[point_id].queue_free()
			point_nodes.erase(point_id)
			print("MainMap: Удалена невыбранная ветка ", point_id)

func update_path_lines() -> void:
	"""Обновляет линии пути"""
	path_line.clear_points()
	path_line.width = PATH_WIDTH
	path_line.default_color = PATH_COLOR
	
	# Получаем видимые точки
	var current_point_data = map_generator.get_point_by_id(map_generator.current_point_id)
	if not current_point_data:
		return
	
	var visible_radius = 2
	var visible_points: Array[int] = []
	for point_data in map_generator.points:
		var distance = current_point_data.position.distance_to(point_data.position)
		if distance <= abs(SPACING_Y) * visible_radius:
			visible_points.append(point_data.id)
	
	# Проходим по всем видимым точкам и рисуем линии связей
	for point_data in map_generator.points:
		if point_data.id not in visible_points:
			continue
			
		for connected_id in point_data.connections:
			var connected_point = map_generator.get_point_by_id(connected_id)
			if connected_point and connected_id in visible_points:
				path_line.add_point(point_data.position)
				path_line.add_point(connected_point.position)

func setup_camera() -> void:
	"""Настраивает камеру"""
	print("MainMap: Настраиваем камеру")
	camera.position = party.position + CAMERA_OFFSET
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 4.0
	print("MainMap: Камера установлена на позицию: ", camera.position)

func _process(_delta: float) -> void:
	"""Обновляет позицию камеры"""
	if camera:
		var target_pos = party.position + CAMERA_OFFSET
		camera.position = camera.position.lerp(target_pos, 0.1)

func update_visible_rooms(current_point_id: int) -> void:
	"""Обновляет видимость комнат - показывает только текущую и ближайшие"""
	print("MainMap: Обновляем видимость комнат от точки ", current_point_id)
	
	var current_point_data = map_generator.get_point_by_id(current_point_id)
	if not current_point_data:
		return
	
	var visible_radius = 2  # Радиус видимости (текущая + 2 комнаты вперед/назад)
	var visible_points: Array[int] = []
	
	# Находим все точки в радиусе видимости
	for point_data in map_generator.points:
		var distance = current_point_data.position.distance_to(point_data.position)
		if distance <= abs(SPACING_Y) * visible_radius:
			visible_points.append(point_data.id)
	
	print("MainMap: Видимые точки: ", visible_points)
	
	# Показываем/скрываем узлы точек
	for point_id in point_nodes.keys():
		var point_node = point_nodes[point_id]
		if point_id in visible_points:
			# Показываем точку
			if not point_node.visible:
				point_node.visible = true
				print("MainMap: Показываем точку ", point_id)
		else:
			# Скрываем точку
			if point_node.visible:
				point_node.visible = false
				print("MainMap: Скрываем точку ", point_id)
