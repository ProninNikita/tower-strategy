extends Node2D

# Ссылки на сцены
@onready var map_generator: Node = $MapGenerator
@onready var party: Node = $Party
@onready var camera: Camera2D = $Camera2D
@onready var path_line: Line2D = $PathLine
@onready var ui_log: Label = $UI/EventLog

# Состояние карты
var map_points: Array = []        # Все точки карты (MapPointData)
var point_nodes: Array = []       # Все узлы точек (MapPoint)
var selected_path_id: int = -1    # ID выбранного пути
var is_path_selected: bool = false # Выбран ли путь

# Настройки камеры
@export var camera_offset: Vector2 = Vector2(0, -50)  # Смещение камеры вверх

func _ready():
	print("ExpeditionMap: Инициализация...")
	
	# Проверяем, что все необходимые узлы найдены
	if not map_generator:
		print("ОШИБКА: MapGenerator не найден!")
		return
	if not party:
		print("ОШИБКА: Party не найден!")
		return
	if not camera:
		print("ОШИБКА: Camera2D не найден!")
		return
	if not path_line:
		print("ОШИБКА: PathLine не найден!")
		return
	
	# Настраиваем камеру
	setup_camera()
	
	# Подключаем сигналы
	connect_signals()
	
	# Генерируем начальный сегмент
	await generate_initial_map()

func setup_camera():
	"""Настраивает камеру"""
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0
		camera.zoom = Vector2(0.8, 0.8)
	else:
		print("ОШИБКА: Камера не найдена!")

func connect_signals():
	"""Подключает все необходимые сигналы"""
	# Сигнал достижения точки отрядом
	party.reached_point.connect(on_party_reached_point)
	party.movement_completed.connect(on_party_movement_completed)

func generate_initial_map():
	"""Генерирует начальную карту"""
	print("Генерируем начальную карту...")
	
	# Генерируем начальный сегмент
	map_points = map_generator.generate_initial_segment()
	
	# Создаем узлы точек
	await create_point_nodes()
	
	# Обновляем линии пути
	update_path_lines()
	
	# Устанавливаем путь для отряда
	set_party_path()
	
	log_message("Карта сгенерирована! Кликните по точке развилки для выбора пути.")

func create_point_nodes():
	"""Создает узлы точек на карте"""
	# Очищаем старые узлы
	for node in point_nodes:
		if is_instance_valid(node):
			node.queue_free()
	point_nodes.clear()
	
	# Создаем новые узлы программно
	for point_data in map_points:
		var point_node = await create_map_point_node(point_data)
		if point_node:
			point_nodes.append(point_node)
	
	print("Создано ", point_nodes.size(), " узлов точек")

func create_map_point_node(point_data) -> Node:
	"""Создает узел точки карты программно"""
	# Создаем Area2D
	var area2d = Area2D.new()
	area2d.position = point_data.position
	
	# Создаем CollisionShape2D
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(40, 40)
	collision_shape.shape = rect_shape
	area2d.add_child(collision_shape)
	
	# Создаем Background (ColorRect)
	var background = ColorRect.new()
	background.name = "Background"  # Важно: устанавливаем имя
	background.anchors_preset = Control.PRESET_CENTER
	background.offset_left = -20.0
	background.offset_top = -20.0
	background.offset_right = 20.0
	background.offset_bottom = 20.0
	background.color = Color.WHITE
	area2d.add_child(background)
	
	# Создаем Icon (Label)
	var icon = Label.new()
	icon.name = "Icon"  # Важно: устанавливаем имя
	icon.anchors_preset = Control.PRESET_CENTER
	icon.offset_left = -15.0
	icon.offset_top = -15.0
	icon.offset_right = 15.0
	icon.offset_bottom = 15.0
	icon.text = "•"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	area2d.add_child(icon)
	
	# Ждем один кадр для правильной инициализации
	await get_tree().process_frame
	
	# Добавляем в сцену
	add_child(area2d)
	
	# Загружаем и устанавливаем скрипт
	var script = load("res://MapPoint.gd")
	if script:
		area2d.set_script(script)
		# Устанавливаем свойства
		area2d.set("point_id", point_data.id)
		area2d.set("event_type", point_data.event_type)
		area2d.set("is_branch_point", point_data.is_branch)
		area2d.set("is_visited", point_data.is_visited)
		area2d.set("is_current", point_data.is_current)
		
		# Подключаем сигнал клика
		area2d.point_clicked.connect(_on_point_selected)
		
		# Обновляем внешний вид
		update_point_appearance_directly(area2d, point_data)
	else:
		print("ПРЕДУПРЕЖДЕНИЕ: Не удалось загрузить MapPoint.gd, создаем простую точку")
		# Fallback: создаем простую точку с метаданными
		area2d.set_meta("point_id", point_data.id)
		area2d.input_event.connect(func(_viewport, event, _shape_idx): _on_simple_point_clicked(point_data.id, event))
		update_simple_point_appearance(area2d, point_data)
	
	return area2d

func update_point_appearance_directly(point_node: Node, point_data):
	"""Обновляет внешний вид точки напрямую"""
	if not point_node.has_method("update_appearance"):
		return
	
	# Устанавливаем свойства
	point_node.set("point_id", point_data.id)
	point_node.set("event_type", point_data.event_type)
	point_node.set("is_branch_point", point_data.is_branch)
	point_node.set("is_visited", point_data.is_visited)
	point_node.set("is_current", point_data.is_current)
	
	# Обновляем внешний вид
	point_node.update_appearance()

func update_simple_point_appearance(point_node: Node, point_data):
	"""Обновляет внешний вид простой точки"""
	var background = point_node.get_node_or_null("Background")
	var icon = point_node.get_node_or_null("Icon")
	
	if background and icon:
		# Устанавливаем цвет в зависимости от состояния
		if point_data.is_current:
			background.color = Color.YELLOW
		elif point_data.is_visited:
			background.color = Color.GRAY
		elif point_data.is_branch:
			background.color = Color.GREEN
		else:
			background.color = Color.WHITE
		
		# Устанавливаем иконку
		var icons = ["•", "⚔️", "🪤", "🛒", "❓"]
		icon.text = icons[point_data.event_type]

func _on_simple_point_clicked(point_id: int, event: InputEvent):
	"""Обрабатывает клик по простой точке"""
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_on_point_selected(point_id)

func _on_point_selected(point_id: int):
	"""Обрабатывает выбор точки игроком"""
	print("Выбрана точка: ", point_id)
	
	# Проверяем, что это точка развилки
	var point_data = get_point_data_by_id(point_id)
	if not point_data or not point_data.is_branch:
		log_message("Эта точка не является развилкой!")
		return
	
	# Сохраняем выбранный путь
	selected_path_id = point_id
	is_path_selected = true
	
	log_message("Выбран путь к точке " + str(point_id))
	
	# Отключаем клики для всех точек
	disable_all_point_clicks()
	
	# Удаляем невыбранные точки
	remove_unselected_points(point_id)
	
	# Генерируем новый сегмент от выбранной точки
	generate_new_segment_from_point(point_id)

func disable_all_point_clicks():
	"""Отключает клики для всех точек"""
	for point_node in point_nodes:
		if is_instance_valid(point_node):
			if point_node.has_method("disable_click"):
				point_node.disable_click()
			else:
				# Для простых точек
				point_node.monitoring = false
				point_node.monitorable = false

func remove_unselected_points(selected_point_id: int):
	"""Удаляет невыбранные точки"""
	var points_to_remove = []
	
	# Находим точки для удаления
	for point_node in point_nodes:
		if is_instance_valid(point_node):
			var point_id = -1
			if point_node.has_method("get_point_id"):
				point_id = point_node.get("point_id")
			elif point_node.has_meta("point_id"):
				point_id = point_node.get_meta("point_id")
			
			if point_id != selected_point_id and point_id != map_generator.current_point_id:
				points_to_remove.append(point_node)
	
	# Удаляем точки
	for point_node in points_to_remove:
		if is_instance_valid(point_node):
			point_node.queue_free()
		point_nodes.erase(point_node)
	
	print("Удалено ", points_to_remove.size(), " невыбранных точек")

func generate_new_segment_from_point(point_id: int):
	"""Генерирует новый сегмент от выбранной точки"""
	# Выбираем путь в генераторе
	map_generator.select_path(point_id)
	
	# Обновляем данные карты
	map_points = map_generator.points
	
	# Создаем новые узлы точек
	await create_point_nodes()
	
	# Обновляем линии пути
	update_path_lines()
	
	# Устанавливаем путь для отряда
	set_party_path()
	
	log_message("Новый сегмент сгенерирован!")

func update_path_lines():
	"""Обновляет линии пути"""
	path_line.clear_points()
	
	# Рисуем все связи между точками
	var connections = map_generator.get_all_connections()
	for connection in connections:
		var from_point = get_point_data_by_id(connection[0])
		var to_point = get_point_data_by_id(connection[1])
		
		if from_point and to_point:
			path_line.add_point(from_point.position)
			path_line.add_point(to_point.position)

func set_party_path():
	"""Устанавливает путь для отряда"""
	var path_points: Array[Vector2] = []
	
	# Получаем путь от текущей точки до следующей
	var current_point = get_current_point_data()
	var next_point = get_next_point_data()
	
	if current_point and next_point:
		path_points.append(current_point.position)
		path_points.append(next_point.position)
		
		# Устанавливаем путь для отряда
		party.set_path(path_points)
		
		log_message("Отряд движется к следующей точке...")

func on_party_reached_point(point_index: int):
	"""Обрабатывает достижение точки отрядом"""
	print("Отряд достиг точки: ", point_index)
	
	# Находим данные точки
	var point_data = get_point_data_by_id(point_index)
	if not point_data:
		return
	
	# Обновляем состояние точки
	point_data.is_visited = true
	point_data.is_current = false
	
	# Обновляем узел точки
	var point_node = get_point_node_by_id(point_index)
	if point_node:
		if point_node.has_method("set_visited"):
			point_node.set_visited(true)
		else:
			# Обновляем простую точку
			if point_node.has_method("set"):
				point_node.set("is_visited", true)
			else:
				point_node.set_meta("is_visited", true)
			update_simple_point_appearance(point_node, point_data)
	
	# Обновляем внешний вид
	if point_node and point_node.has_method("update_appearance"):
		point_node.update_appearance()
	
	# Логируем событие
	var event_name = "Неизвестно"
	if point_node and point_node.has_method("get_event_type_name"):
		event_name = point_node.get_event_type_name()
	else:
		# Для простых точек
		var event_names = ["Пусто", "Бой", "Ловушка", "Торговец", "Случайное"]
		event_name = event_names[point_data.event_type]
	
	log_message("Достигнута точка " + str(point_index) + " - " + event_name)
	
	# Проверяем, достигли ли конца сегмента
	if map_generator.is_at_segment_end():
		log_message("Достигнут конец сегмента - выберите путь для продолжения")
		enable_branch_point_clicks()

func enable_branch_point_clicks():
	"""Включает клики по точкам развилок"""
	var branch_points = map_generator.get_branch_points()
	
	for point_node in point_nodes:
		if is_instance_valid(point_node):
			var point_id = -1
			if point_node.has_method("get_point_id"):
				point_id = point_node.get("point_id")
			elif point_node.has_meta("point_id"):
				point_id = point_node.get_meta("point_id")
			
			# Проверяем, является ли это точкой развилки
			for branch_point in branch_points:
				if branch_point.id == point_id:
					# Включаем клики для этой точки
					point_node.monitoring = true
					point_node.monitorable = true
					break

func on_party_movement_completed():
	"""Обрабатывает завершение движения отряда"""
	print("Движение отряда завершено")

func get_point_data_by_id(id: int):
	"""Возвращает данные точки по ID"""
	for point_data in map_points:
		if point_data.id == id:
			return point_data
	return null

func get_point_node_by_id(id: int) -> Node:
	"""Возвращает узел точки по ID"""
	for point_node in point_nodes:
		# Проверяем точки со скриптом
		if point_node.has_method("get_point_id") and point_node.get("point_id") == id:
			return point_node
		# Проверяем простые точки
		elif point_node.has_meta("point_id") and point_node.get_meta("point_id") == id:
			return point_node
	return null

func get_current_point_data():
	"""Возвращает данные текущей точки"""
	return get_point_data_by_id(map_generator.current_point_id)

func get_next_point_data():
	"""Возвращает данные следующей точки"""
	var current_point = get_current_point_data()
	if not current_point:
		return null
	
	var connections = map_generator.get_connections_for_point(current_point.id)
	for connection in connections:
		var connected_point = get_point_data_by_id(connection)
		if connected_point and not connected_point.is_visited:
			return connected_point
	
	return null

func _process(delta):
	"""Обновляет позицию камеры"""
	if camera and party:
		var target_position = party.get_current_position() + camera_offset
		camera.position = target_position

func log_message(message: String):
	"""Логирует сообщение в UI"""
	if ui_log:
		ui_log.text += message + "\n"
		# Ограничиваем длину текста для Label
		if ui_log.text.length() > 1000:
			ui_log.text = ui_log.text.right(-500)
	print(message) 
