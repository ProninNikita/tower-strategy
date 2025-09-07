extends Node2D

@export var team_size: int = 3

var heroes: Array[Node] = []
var event_manager: Node
var map_controller: Node
var movement_paused: bool = false
var expedition_ended: bool = false

func _ready():
	# Находим EventManager и MapController
	event_manager = get_node("../EventManager")
	map_controller = get_node("../MapController")
	
	# Создаем команду героев
	create_team()

func create_team():
	"""Создает команду героев"""
	heroes.clear()
	
	# Цвета для героев
	var hero_colors = [Color.BLUE, Color.RED, Color.GREEN]
	
	for i in range(team_size):
		var hero_scene = preload("res://Hero.tscn")
		var hero = hero_scene.instantiate()
		
		# Настраиваем героя
		hero.hero_index = i
		hero.hero_color = hero_colors[i]
		
		# Добавляем в сцену
		add_child(hero)
		heroes.append(hero)

func on_hero_reached_point(_hero_index: int, point_index: int):
	"""Обрабатывает достижение точки героем"""
	# Получаем текущий узел карты
	if not map_controller:
		return
		
	var current_node = map_controller.get_current_node()
	if current_node:
		# Запускаем событие узла
		if event_manager and event_manager.has_method("trigger_event_by_type"):
			event_manager.trigger_event_by_type(current_node.event_type)
		
		# Проверяем, достигли ли конца сегмента
		if map_controller.has_method("check_segment_end"):
			map_controller.check_segment_end()
	
	print("Команда достигла узла " + str(current_node.id if current_node else "неизвестно"))

func pause_movement():
	"""Приостанавливает движение команды"""
	movement_paused = true
	for hero in heroes:
		if hero.has_method("set_movement_paused"):
			hero.set_movement_paused(true)

func resume_movement():
	"""Возобновляет движение команды"""
	movement_paused = false
	for hero in heroes:
		if hero.has_method("set_movement_paused"):
			hero.set_movement_paused(false)

func end_expedition():
	"""Завершает поход"""
	expedition_ended = true
	for hero in heroes:
		if hero.has_method("stop_movement"):
			hero.stop_movement()
	print("Поход завершен!")

func get_heroes():
	"""Возвращает массив героев"""
	return heroes

func get_team_size():
	"""Возвращает размер команды"""
	return team_size 