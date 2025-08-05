extends Node2D

signal dungeon_completed(level: int, rewards: Dictionary)
signal player_died

var dungeon_level: int = 15
var dungeon_settings: Dictionary = {}
var dungeon_map: Array = []
var player_position: Vector2 = Vector2(1, 1)
var exit_position: Vector2 = Vector2(18, 13)

# Типы клеток
enum CellType {
	WALL = 0,
	FLOOR = 1,
	ENEMY = 2,
	TREASURE = 3,
	EXIT = 4
}

func _ready():
	print("DungeonScene: Инициализация подземелья уровня ", dungeon_level)
	
	# Подключаем кнопку "Назад"
	var back_button = $DungeonUI/TopBar/BackButton
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	
	# Обновляем UI
	update_ui()

func generate_dungeon_map():
	print("DungeonScene: Генерируем карту подземелья...")
	
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	# Инициализируем пустую карту
	dungeon_map = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(CellType.WALL)
		dungeon_map.append(row)
	
	# Генерируем комнаты
	generate_rooms()
	
	# Добавляем врагов и сокровища
	place_enemies_and_treasures()
	
	# Размещаем выход
	place_exit()
	
	# Визуализируем карту
	visualize_dungeon()
	
	print("DungeonScene: Карта подземелья сгенерирована")

func generate_rooms():
	var room_count = dungeon_settings.get("room_count", 8)
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	for i in range(room_count):
		var room_width = randi_range(3, 6)
		var room_height = randi_range(3, 6)
		var x = randi_range(1, width - room_width - 1)
		var y = randi_range(1, height - room_height - 1)
		
		# Создаем комнату
		for room_y in range(y, y + room_height):
			for room_x in range(x, x + room_width):
				if room_y < dungeon_map.size() and room_x < dungeon_map[room_y].size():
					dungeon_map[room_y][room_x] = CellType.FLOOR
	
	# Создаем коридоры между комнатами
	create_corridors()

func create_corridors():
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	# Простая генерация коридоров
	for y in range(1, height - 1, 2):
		for x in range(1, width - 1):
			dungeon_map[y][x] = CellType.FLOOR
	
	for x in range(1, width - 1, 2):
		for y in range(1, height - 1):
			dungeon_map[y][x] = CellType.FLOOR

func place_enemies_and_treasures():
	var enemy_density = dungeon_settings.get("enemy_density", 0.3)
	var treasure_density = dungeon_settings.get("treasure_density", 0.2)
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	for y in range(height):
		for x in range(width):
			if dungeon_map[y][x] == CellType.FLOOR:
				var rand = randf()
				if rand < enemy_density:
					dungeon_map[y][x] = CellType.ENEMY
				elif rand < enemy_density + treasure_density:
					dungeon_map[y][x] = CellType.TREASURE

func place_exit():
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	# Ищем подходящее место для выхода
	for y in range(height - 1, 0, -1):
		for x in range(width - 1, 0, -1):
			if dungeon_map[y][x] == CellType.FLOOR:
				dungeon_map[y][x] = CellType.EXIT
				exit_position = Vector2(x, y)
				return

func visualize_dungeon():
	# Очищаем предыдущую визуализацию
	var dungeon_grid = $DungeonGrid
	for child in dungeon_grid.get_children():
		child.queue_free()
	
	var cell_size = 32
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	# Создаем фон для карты
	var map_background = ColorRect.new()
	map_background.size = Vector2(width * cell_size, height * cell_size)
	map_background.position = Vector2(0, 0)
	map_background.color = Color.BLACK
	dungeon_grid.add_child(map_background)
	
	for y in range(height):
		for x in range(width):
			var cell_type = dungeon_map[y][x]
			var cell_rect = ColorRect.new()
			cell_rect.size = Vector2(cell_size - 1, cell_size - 1)  # Небольшой отступ между клетками
			cell_rect.position = Vector2(x * cell_size + 0.5, y * cell_size + 0.5)
			
			match cell_type:
				CellType.WALL:
					cell_rect.color = Color(0.3, 0.3, 0.3, 1)  # Темно-серый
				CellType.FLOOR:
					cell_rect.color = Color(0.7, 0.7, 0.7, 1)  # Светло-серый
				CellType.ENEMY:
					cell_rect.color = Color(0.8, 0.2, 0.2, 1)  # Красный
				CellType.TREASURE:
					cell_rect.color = Color(1.0, 0.8, 0.0, 1)  # Золотой
				CellType.EXIT:
					cell_rect.color = Color(0.2, 0.8, 0.2, 1)  # Зеленый
			
			dungeon_grid.add_child(cell_rect)
	
	# Размещаем игрока
	var player = $Player
	player.position = Vector2(player_position.x * cell_size + cell_size/2, 
							 player_position.y * cell_size + cell_size/2)

func update_ui():
	var level_label = $DungeonUI/TopBar/LevelLabel
	if level_label:
		level_label.text = "Подземелье Ур. " + str(dungeon_level)

func _on_back_button_pressed():
	print("DungeonScene: Кнопка 'Назад' нажата")
	# Возвращаемся в город
	queue_free()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W, KEY_UP:
				move_player(Vector2(0, -1))
			KEY_S, KEY_DOWN:
				move_player(Vector2(0, 1))
			KEY_A, KEY_LEFT:
				move_player(Vector2(-1, 0))
			KEY_D, KEY_RIGHT:
				move_player(Vector2(1, 0))
			KEY_ESCAPE:
				_on_back_button_pressed()

func move_player(direction: Vector2):
	var new_position = player_position + direction
	var width = dungeon_settings.get("width", 20)
	var height = dungeon_settings.get("height", 15)
	
	# Проверяем границы
	if new_position.x < 0 or new_position.x >= width or \
	   new_position.y < 0 or new_position.y >= height:
		return
	
	# Проверяем тип клетки
	var cell_type = dungeon_map[new_position.y][new_position.x]
	
	match cell_type:
		CellType.WALL:
			return  # Нельзя пройти через стену
		CellType.ENEMY:
			# Бой с врагом
			print("DungeonScene: Бой с врагом!")
			start_combat(new_position)
			return
		CellType.TREASURE:
			# Подбираем сокровище
			print("DungeonScene: Найдено сокровище!")
			dungeon_map[new_position.y][new_position.x] = CellType.FLOOR
		CellType.EXIT:
			# Выход из подземелья
			print("DungeonScene: Выход найден! Подземелье пройдено!")
			complete_dungeon()
			return
	
	# Перемещаем игрока
	player_position = new_position
	var player = $Player
	var cell_size = 32
	player.position = Vector2(player_position.x * cell_size + cell_size/2, 
							 player_position.y * cell_size + cell_size/2)

func start_combat(enemy_position: Vector2):
	print("DungeonScene: Начинается бой!")
	# Здесь будет логика боя
	# Пока просто удаляем врага
	dungeon_map[enemy_position.y][enemy_position.x] = CellType.FLOOR
	visualize_dungeon()

func complete_dungeon():
	var rewards = {
		"experience": dungeon_level * 100,
		"gold": dungeon_level * 50,
		"items": []
	}
	
	print("DungeonScene: Подземелье пройдено! Награды: ", rewards)
	dungeon_completed.emit(dungeon_level, rewards) 