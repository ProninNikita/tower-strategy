extends Node2D

const PointMarker = preload("res://scenes/PointMarker.tscn")

@export var move_speed: float = 100.0
@export var hero_color: Color = Color.BLUE
@export var hero_index: int = 0  # Индекс героя в команде (0, 1, 2)

var path_points: Array[Vector2] = []
var current_point_index: int = 0
var is_moving: bool = false
var event_manager: Node
var team_manager: Node
var movement_paused: bool = false

func _ready():
	# Создаем визуальное представление героя
	var hero_sprite = ColorRect.new()
	hero_sprite.size = Vector2(20, 20)
	hero_sprite.position = Vector2(-10, -10)  # Центрируем
	hero_sprite.color = hero_color
	add_child(hero_sprite)
	
	# Получаем путь из MapController
	var map_controller = get_node("../../MapController")
	if map_controller and map_controller.has_method("get_current_node"):
		update_path_from_map(map_controller)
	else:
		print("ПРЕДУПРЕЖДЕНИЕ: MapController не найден или не готов для героя ", hero_index)
	
	# Находим TeamManager
	team_manager = get_node("../../TeamManager")
	
	# Находим EventManager
	event_manager = get_node("../../EventManager")
	
	# Устанавливаем начальную позицию с учетом смещения в команде
	var offset = Vector2(hero_index * 15, 0)  # Смещение по X для каждого героя
	if path_points.size() > 0:
		position = path_points[0] + offset
	else:
		print("ПРЕДУПРЕЖДЕНИЕ: path_points пуст в _ready() для героя ", hero_index)
		position = Vector2.ZERO + offset
	
	# Начинаем движение
	start_movement()

func _process(delta):
	if path_points.size() == 0:
		return
	if is_moving and current_point_index < path_points.size() and not movement_paused:
		var target_point = path_points[current_point_index]
		var offset = Vector2(hero_index * 15, 0)  # Смещение в команде
		var target_with_offset = target_point + offset
		
		var direction = (target_with_offset - position).normalized()
		var distance = position.distance_to(target_with_offset)
		
		if distance > 1.0:
			position += direction * move_speed * delta
		else:
			# Достигли точки
			position = target_with_offset
			on_reached_point()
			current_point_index += 1
			
			if current_point_index >= path_points.size():
				is_moving = false
				print("Герой " + str(hero_index) + " завершил путь!")

func update_path_from_map(map_controller: Node):
	"""Обновляет путь героя на основе текущего состояния карты"""
	# Получаем текущий узел и доступные пути
	var current_node = map_controller.get_current_node()
	var available_paths = map_controller.get_available_paths()
	
	print("DEBUG: current_node = ", current_node, " для героя ", hero_index)
	print("DEBUG: available_paths.size() = ", available_paths.size(), " для героя ", hero_index)
	
	if current_node:
		# Если есть доступные пути, выбираем первый
		if available_paths.size() > 0:
			var next_node = available_paths[0]
			path_points = [current_node.position, next_node.position]
		else:
			# Если нет доступных путей, остаемся на месте
			path_points = [current_node.position]
	else:
		print("ПРЕДУПРЕЖДЕНИЕ: current_node = null для героя ", hero_index)
		path_points = [Vector2.ZERO]  # Временная позиция
	
	# Обновляем позицию героя
	if path_points.size() > 0:
		var offset = Vector2(hero_index * 15, 0)
		position = path_points[0] + offset
	else:
		print("ПРЕДУПРЕЖДЕНИЕ: path_points пуст в update_path_from_map() для героя ", hero_index)

func start_movement():
	"""Начинает движение героя"""
	if path_points.size() < 2:
		print("ПРЕДУПРЕЖДЕНИЕ: Недостаточно точек для движения героя ", hero_index)
		is_moving = false
		return
	is_moving = true
	current_point_index = 1  # Начинаем со второй точки, так как первая - стартовая

func on_reached_point():
	"""Обрабатывает достижение точки"""
	# Уведомляем TeamManager о достижении точки
	if team_manager and team_manager.has_method("on_hero_reached_point"):
		team_manager.on_hero_reached_point(hero_index, current_point_index - 1)

func set_movement_paused(paused: bool):
	"""Устанавливает состояние паузы движения"""
	movement_paused = paused

func stop_movement():
	"""Останавливает движение героя"""
	is_moving = false 
