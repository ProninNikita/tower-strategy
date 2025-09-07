extends Node2D

enum EventType {
	EMPTY,
	BATTLE,
	TRAP,
	MERCHANT,
	RANDOM
}

var event_log_label: Label
var team_manager: Node
var is_battle_active: bool = false
var battle_scene: Node

func _ready():
	# Находим Label для логов
	event_log_label = get_node("../UI/EventLog")
	
	# Находим TeamManager
	team_manager = get_node("../TeamManager")
	
	# Инициализируем систему событий
	initialize_event_system()

func initialize_event_system():
	"""Инициализирует систему событий для сегментной карты"""
	log_message("Система событий готова к работе с сегментной картой")

func trigger_event_by_type(event_type: int):
	"""Запускает событие по типу"""
	var event_name = get_event_name(event_type)
	log_message("Герой достиг узла - " + event_name)
	
	# Вызываем соответствующее событие
	match event_type:
		1:  # BATTLE
			handle_battle()
		2:  # TRAP
			handle_trap()
		3:  # MERCHANT
			handle_merchant()
		4:  # RANDOM
			handle_random()
		0:  # EMPTY
			handle_empty()

func get_event_name(event_type: int) -> String:
	"""Возвращает название типа события"""
	match event_type:
		0:  # EMPTY
			return "Пусто"
		1:  # BATTLE
			return "Бой"
		2:  # TRAP
			return "Ловушка"
		3:  # MERCHANT
			return "Торговец"
		4:  # RANDOM
			return "Случайное событие"
		_:
			return "Неизвестно"

func handle_battle():
	"""Обрабатывает событие боя"""
	if is_battle_active:
		log_message("  -> Бой уже идет!")
		return
	
	log_message("  -> Начинается бой!")
	is_battle_active = true
	
	# Приостанавливаем движение команды
	if team_manager and team_manager.has_method("pause_movement"):
		team_manager.pause_movement()
	
	# Создаем сцену боя
	create_battle_scene()

func handle_trap():
	"""Обрабатывает событие ловушки"""
	log_message("  -> Сработала ловушка!")
	# Здесь можно добавить логику ловушки (потеря HP, эффекты и т.д.)

func handle_merchant():
	"""Обрабатывает событие торговца"""
	log_message("  -> Встречен торговец!")
	# Здесь можно добавить логику торговца (покупка предметов и т.д.)

func handle_random():
	"""Обрабатывает случайное событие"""
	log_message("  -> Произошло случайное событие!")
	# Здесь можно добавить логику случайных событий

func handle_empty():
	"""Обрабатывает пустое событие"""
	log_message("  -> Ничего не произошло")

func create_battle_scene():
	"""Создает сцену боя"""
	var battle_scene_scene = preload("res://scenes/BattleScene.tscn")
	battle_scene = battle_scene_scene.instantiate()
	
	# Добавляем сцену боя в главную сцену
	get_parent().add_child(battle_scene)
	
	# Подключаем сигнал завершения боя
	if battle_scene.has_signal("battle_finished"):
		battle_scene.battle_finished.connect(on_battle_finished)
	
	# Запускаем бой
	battle_scene.start_battle()

func on_battle_finished(victory: bool):
	"""Обрабатывает завершение боя"""
	is_battle_active = false
	
	if victory:
		log_message("  -> Победа в бою!")
	else:
		log_message("  -> Поражение в бою!")
		# Здесь можно добавить логику поражения
	
	# Удаляем сцену боя
	if battle_scene and is_instance_valid(battle_scene):
		battle_scene.queue_free()
		battle_scene = null
	
	# Возобновляем движение команды
	if team_manager and team_manager.has_method("resume_movement"):
		team_manager.resume_movement()

func log_message(message: String):
	"""Добавляет сообщение в лог событий"""
	if event_log_label:
		event_log_label.text += message + "\n"
		# Прокручиваем к концу
		event_log_label.text = event_log_label.text.right(-1000) if event_log_label.text.length() > 1000 else event_log_label.text
	print(message) 
