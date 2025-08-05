extends Node

signal dungeon_generated(dungeon_scene)
signal dungeon_completed(level: int, rewards: Dictionary)

var current_dungeon_level: int = 15
var dungeon_scene: Node = null
var is_dungeon_active: bool = false

# Настройки генерации подземелья
var dungeon_settings = {
	"width": 20,
	"height": 15,
	"room_count": 8,
	"enemy_density": 0.3,
	"treasure_density": 0.2
}

func _ready():
	print("DungeonManager: Инициализирован")

func generate_dungeon(level: int) -> Node:
	print("DungeonManager: Генерируем подземелье уровня ", level)
	
	# Создаем новую сцену подземелья
	var dungeon_scene = load("res://DungeonScene.tscn").instantiate()
	dungeon_scene.dungeon_level = level
	dungeon_scene.dungeon_settings = dungeon_settings
	
	# Генерируем карту подземелья
	dungeon_scene.generate_dungeon_map()
	
	# Подключаем сигналы
	dungeon_scene.dungeon_completed.connect(_on_dungeon_completed)
	dungeon_scene.player_died.connect(_on_player_died)
	
	self.dungeon_scene = dungeon_scene
	is_dungeon_active = true
	
	print("DungeonManager: Подземелье сгенерировано успешно")
	dungeon_generated.emit(dungeon_scene)
	
	return dungeon_scene

func start_dungeon_run(level: int) -> bool:
	if is_dungeon_active:
		print("DungeonManager: Подземелье уже активно!")
		return false
	
	print("DungeonManager: Начинаем забег в подземелье уровня ", level)
	
	# Генерируем подземелье
	var dungeon = generate_dungeon(level)
	
	# Переключаемся на сцену подземелья
	var main_scene = get_tree().current_scene
	if main_scene.has_node("CityUI"):
		main_scene.get_node("CityUI").hide()
	
	# Добавляем подземелье в сцену
	main_scene.add_child(dungeon)
	
	return true

func _on_dungeon_completed(level: int, rewards: Dictionary):
	print("DungeonManager: Подземелье уровня ", level, " пройдено!")
	print("DungeonManager: Награды: ", rewards)
	
	# Обновляем уровень игрока
	current_dungeon_level = level + 1
	
	# Удаляем сцену подземелья
	if dungeon_scene:
		dungeon_scene.queue_free()
		dungeon_scene = null
	
	is_dungeon_active = false
	
	# Показываем городской UI снова
	var main_scene = get_tree().current_scene
	if main_scene.has_node("CityUI"):
		main_scene.get_node("CityUI").show()
		# Обновляем отображение уровня
		main_scene.get_node("CityUI").update_dungeon_level(current_dungeon_level)
	
	dungeon_completed.emit(level, rewards)

func _on_player_died():
	print("DungeonManager: Игрок погиб в подземелье!")
	
	# Удаляем сцену подземелья
	if dungeon_scene:
		dungeon_scene.queue_free()
		dungeon_scene = null
	
	is_dungeon_active = false
	
	# Показываем городской UI снова
	var main_scene = get_tree().current_scene
	if main_scene.has_node("CityUI"):
		main_scene.get_node("CityUI").show()

func get_current_level() -> int:
	return current_dungeon_level

func is_dungeon_running() -> bool:
	return is_dungeon_active 