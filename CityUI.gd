extends Control

# Сигналы для связи с другими системами игры
signal dungeon_run_requested
signal hero_portal_opened
signal hero_mansion_opened

# Данные игрока (в реальном проекте будут загружаться из сохранений)
var player_data = {
	"dungeon_level": 15,
	"available_summons": 3,
	"total_heroes": 12
}

# Ссылка на менеджер подземелий
var dungeon_manager: Node = null

func _ready():
	# Настройка для мобильных устройств
	setup_mobile_ui()
	
	# Находим менеджер подземелий
	find_dungeon_manager()
	
	# Обновляем отображение данных
	update_ui_data()
	
	# Подключаем сигналы от кнопок
	connect_button_signals()

func setup_mobile_ui():
	# Устанавливаем соотношение сторон 9:16 для мобильных устройств
	var viewport = get_viewport()
	if viewport:
		# В Godot 4 используем правильные свойства для viewport
		viewport.size = Vector2(360, 640)  # 9:16 соотношение
		# Убираем неправильное свойство size_2d_override_stretch

func connect_button_signals():
	# Подключаем сигналы от кнопок к соответствующим функциям
	var tower_button = $BottomBar/DungeonTowerButton
	var portal_button = $BottomBar/HeroPortalButton
	var mansion_button = $BottomBar/HeroMansionButton
	
	if tower_button:
		tower_button.pressed.connect(_on_tower_button_pressed)
	if portal_button:
		portal_button.pressed.connect(_on_portal_button_pressed)
	if mansion_button:
		mansion_button.pressed.connect(_on_mansion_button_pressed)

func update_ui_data():
	# Обновляем отображение данных игрока
	var dungeon_level_label = $BottomBar/DungeonTowerButton/DungeonLevel
	var summon_count_label = $BottomBar/HeroPortalButton/SummonCount
	var hero_count_label = $BottomBar/HeroMansionButton/HeroCount
	
	if dungeon_level_label:
		dungeon_level_label.text = "Ур. " + str(player_data.dungeon_level)
	if summon_count_label:
		summon_count_label.text = str(player_data.available_summons) + "x"
	if hero_count_label:
		hero_count_label.text = str(player_data.total_heroes)

func find_dungeon_manager():
	# Ищем менеджер подземелий в родительской сцене
	var parent = get_parent()
	if parent:
		dungeon_manager = parent.get_node_or_null("DungeonManager")
		if dungeon_manager:
			print("CityUI: Менеджер подземелий найден")
		else:
			print("CityUI: Менеджер подземелий не найден")

func _on_tower_button_pressed():
	print("Запрос на запуск подземелья")
	dungeon_run_requested.emit()
	
	# Запускаем подземелье через менеджер
	if dungeon_manager:
		var success = dungeon_manager.start_dungeon_run(player_data.dungeon_level)
		if success:
			hide()  # Скрываем городской UI
		else:
			print("CityUI: Не удалось запустить подземелье")
	else:
		print("CityUI: Менеджер подземелий недоступен")

func _on_portal_button_pressed():
	print("Открытие портала героев")
	hero_portal_opened.emit()
	
	# Проверяем, есть ли доступные призывы
	if player_data.available_summons <= 0:
		show_message("Нет доступных призывов!")
		return

func _on_mansion_button_pressed():
	print("Открытие особняка героев")
	hero_mansion_opened.emit()

func show_message(message: String):
	# Простая функция для показа сообщений
	# В реальном проекте здесь будет полноценный UI для уведомлений
	print("Сообщение: ", message)
	
	# Можно добавить анимацию появления сообщения
	var tween = create_tween()
	# Здесь будет логика анимации сообщения

# Функции для обновления данных (вызываются из других систем)
func update_dungeon_level(level: int):
	player_data.dungeon_level = level
	update_ui_data()

func update_summon_count(count: int):
	player_data.available_summons = count
	update_ui_data()

func update_hero_count(count: int):
	player_data.total_heroes = count
	update_ui_data()

# Функция для переключения на другие экраны
func switch_to_scene(scene_path: String):
	# В реальном проекте здесь будет логика переключения сцен
	print("Переключение на сцену: ", scene_path)
	# get_tree().change_scene_to_file(scene_path) 
