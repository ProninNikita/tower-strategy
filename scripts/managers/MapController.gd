extends Node2D

# Ссылки на узлы
var map_generator: Node
var path_line: Line2D
var background: ColorRect
var camera: Camera2D
var event_manager: Node
var team_manager: Node

# Настройки отображения
var node_size: Vector2 = Vector2(30, 30)
var event_node_size: Vector2 = Vector2(40, 40)
var line_width: float = 3.0
var line_color: Color = Color(0.7, 0.7, 0.7, 1.0)
var visited_line_color: Color = Color(0.3, 0.3, 0.3, 1.0)

# Состояние карты
var map_nodes: Array = []
var node_markers: Array[Node] = []
var is_choosing_path: bool = false
var available_paths: Array = []

func _ready():
	# Находим узлы
	path_line = get_node("../PathLine")
	background = get_node("../Background")
	camera = get_node("../Camera2D")
	event_manager = get_node("../EventManager")
	team_manager = get_node("../TeamManager")
	
	# Создаем генератор карты
	var MapGeneratorScript = load("res://scripts/gameplay/MapGenerator.gd")
	if not MapGeneratorScript:
		print("ОШИБКА: Не удалось загрузить MapGenerator.gd!")
		return
	map_generator = MapGeneratorScript.new()
	if not map_generator:
		print("ОШИБКА: Не удалось создать экземпляр MapGenerator!")
		return
	print("MapGenerator успешно создан!")
	add_child(map_generator)
	
	# Генерируем начальный сегмент
	generate_new_map()
	
	# Настраиваем камеру
	setup_camera()

func generate_new_map():
	"""Генерирует новую карту с начальным сегментом"""
	# Генерируем начальный сегмент
	map_nodes = map_generator.generate_initial_segment()
	
	# Очищаем старые маркеры
	clear_node_markers()
	
	# Создаем маркеры узлов
	create_node_markers()
	
	# Обновляем линии пути
	update_path_lines()
	
	# Центрируем камеру на текущем узле
	center_camera_on_current_node()

func clear_node_markers():
	"""Очищает все маркеры узлов"""
	for marker in node_markers:
		if is_instance_valid(marker):
			marker.queue_free()
	node_markers.clear()

func create_node_markers():
	"""Создает маркеры для всех узлов карты"""
	for node in map_nodes:
		var marker = create_node_marker(node)
		node_markers.append(marker)
		add_child(marker)

func create_node_marker(node: Node) -> Node2D:
	"""Создает маркер для узла карты"""
	var marker = Node2D.new()
	marker.position = node.position
	
	# Создаем фон узла
	var background_rect = ColorRect.new()
	var size = event_node_size if node.event_type != 0 else node_size  # 0 = EMPTY
	background_rect.size = size
	background_rect.position = -size / 2
	
	# Устанавливаем цвет в зависимости от состояния
	if node.is_current:
		background_rect.color = Color.YELLOW
	elif node.visited:
		background_rect.color = Color.GRAY
	else:
		background_rect.color = Color.WHITE
	
	marker.add_child(background_rect)
	
	# Создаем иконку события
	var icon_label = Label.new()
	if not map_generator:
		print("ОШИБКА: map_generator не создан в create_node_marker()!")
		icon_label.text = "?"
	else:
		icon_label.text = map_generator.get_event_type_icon(node.event_type)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.size = size
	icon_label.position = -size / 2
	
	# Устанавливаем цвет иконки
	if node.is_current:
		icon_label.modulate = Color.BLACK
	elif node.visited:
		icon_label.modulate = Color.DARK_GRAY
	else:
		icon_label.modulate = Color.BLACK
	
	marker.add_child(icon_label)
	
	# Добавляем обработчик клика через Control
	var control = Control.new()
	control.size = size
	control.position = -size / 2
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Создаем уникальную функцию для этого узла
	var node_id = node.id
	control.gui_input.connect(func(event): _on_node_gui_input(node_id, event))
	marker.add_child(control)
	
	return marker

func _on_node_gui_input(node_id: int, event: InputEvent):
	"""Обрабатывает клики по узлам карты"""
	if not event is InputEventMouseButton:
		return
	
	var mouse_event = event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	# Получаем узел по ID
	var node = map_generator.get_node_by_id(node_id)
	if not node:
		print("ОШИБКА: Не удалось найти узел с ID ", node_id)
		return
	
	# Если мы выбираем путь, проверяем доступность узла
	if is_choosing_path:
		if node in available_paths:
			select_path(node)
		return
	
	# Если это текущий узел и есть доступные пути, начинаем выбор
	if node.is_current:
		available_paths = map_generator.get_available_paths()
		if available_paths.size() > 1:
			start_path_selection()

func start_path_selection():
	"""Начинает выбор пути"""
	is_choosing_path = true
	
	# Подсвечиваем доступные пути
	for path_node in available_paths:
		var marker = get_node_marker_by_id(path_node.id)
		if marker:
			var background = marker.get_child(0) as ColorRect
			background.color = Color.GREEN
	
	# Приостанавливаем движение команды
	if team_manager and team_manager.has_method("pause_movement"):
		team_manager.pause_movement()
	
	event_manager.log_message("Выберите путь для продолжения похода")

func select_path(selected_node: Node):
	"""Выбирает путь и генерирует новый сегмент"""
	is_choosing_path = false
	
	# Убираем подсветку
	for path_node in available_paths:
		var marker = get_node_marker_by_id(path_node.id)
		if marker:
			var background = marker.get_child(0) as ColorRect
			if path_node == selected_node:
				background.color = Color.YELLOW  # Выбранный узел
			else:
				background.color = Color.WHITE   # Остальные узлы
	
	# Вызываем генератор карты для выбора пути
	map_generator.select_path(selected_node.id)
	
	# Обновляем данные карты
	map_nodes = map_generator.nodes
	
	# Обновляем маркеры
	update_node_markers()
	
	# Обновляем линии пути
	update_path_lines()
	
	# Центрируем камеру на новом узле
	center_camera_on_current_node()
	
	# Запускаем событие узла
	trigger_node_event(selected_node)
	
	# Возобновляем движение команды
	if team_manager and team_manager.has_method("resume_movement"):
		team_manager.resume_movement()

func trigger_node_event(node: Node):
	"""Запускает событие узла"""
	if not map_generator:
		print("ОШИБКА: map_generator не создан в trigger_node_event()!")
		return
	event_manager.log_message("Достигнута точка " + str(node.id) + " - " + map_generator.get_event_type_name(node.event_type))
	
	# Вызываем соответствующее событие
	match node.event_type:
		1:  # BATTLE
			event_manager.handle_battle()
		2:  # TRAP
			event_manager.handle_trap()
		3:  # MERCHANT
			event_manager.handle_merchant()
		4:  # RANDOM
			event_manager.handle_random()
		0:  # EMPTY
			event_manager.handle_empty()

func update_node_markers():
	"""Обновляет визуальное состояние маркеров узлов"""
	for i in range(map_nodes.size()):
		var node = map_nodes[i]
		var marker = node_markers[i]
		
		if not is_instance_valid(marker):
			continue
		
		var background = marker.get_child(0) as ColorRect
		var icon = marker.get_child(1) as Label
		
		# Обновляем цвет фона
		if node.is_current:
			background.color = Color.YELLOW
			icon.modulate = Color.BLACK
		elif node.visited:
			background.color = Color.GRAY
			icon.modulate = Color.DARK_GRAY
		else:
			background.color = Color.WHITE
			icon.modulate = Color.BLACK

func update_path_lines():
	"""Обновляет линии пути"""
	if not map_generator:
		print("ОШИБКА: map_generator не создан в update_path_lines()!")
		return
		
	path_line.clear_points()
	
	# Рисуем все связи между узлами
	for node in map_nodes:
		for connection_id in node.connections:
			var connected_node = map_generator.get_node_by_id(connection_id)
			if connected_node:
				# Добавляем точки линии
				path_line.add_point(node.position)
				path_line.add_point(connected_node.position)
	
	# Устанавливаем цвет линии в зависимости от состояния
	# Для простоты используем основной цвет, можно улучшить позже
	path_line.default_color = line_color

func get_node_marker_by_id(id: int) -> Node2D:
	"""Возвращает маркер узла по ID"""
	for i in range(map_nodes.size()):
		if map_nodes[i].id == id:
			return node_markers[i]
	return null

func center_camera_on_current_node():
	"""Центрирует камеру на текущем узле"""
	if not map_generator:
		print("ОШИБКА: map_generator не создан в center_camera_on_current_node()!")
		return
	var current_node = map_generator.get_node_by_id(map_generator.current_node_id)
	if current_node and camera:
		camera.position = current_node.position

func setup_camera():
	"""Настраивает камеру"""
	if camera:
		camera.enabled = true
		camera.zoom = Vector2(0.8, 0.8)  # Немного отдаляем камеру

func get_current_node() -> Node:
	"""Возвращает текущий узел"""
	if not map_generator:
		print("ОШИБКА: map_generator не создан в get_current_node()!")
		return null
	return map_generator.get_node_by_id(map_generator.current_node_id)

func get_available_paths() -> Array:
	"""Возвращает доступные пути"""
	if not map_generator:
		print("ОШИБКА: map_generator не создан в get_available_paths()!")
		return []
	return map_generator.get_available_paths()

func check_segment_end():
	"""Проверяет, достиг ли команда конца сегмента"""
	if not map_generator:
		return false
	
	if map_generator.is_at_segment_end():
		# Команда достигла конца сегмента
		event_manager.log_message("Достигнут конец сегмента - выберите путь для продолжения")
		start_path_selection()
		return true
	
	return false 
