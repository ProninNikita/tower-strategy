extends CanvasLayer

signal battle_finished(victory: bool)

# Структуры для персонажей
var heroes = []
var enemies = []
var is_battle_active = false
var current_turn = 0

# UI элементы
var battle_log: RichTextLabel
var result_label: Label

# Настройки боя
var turn_delay = 1.0
var attack_animation_duration = 0.3
var damage_flash_duration = 0.2

func _ready():
	# Инициализируем случайный генератор
	randomize()
	
	# Находим UI элементы
	battle_log = $BattleLogPanel/BattleLog
	result_label = $BattleZone/ResultLabel

func start_battle():
	# Показываем сцену
	visible = true
	is_battle_active = true
	current_turn = 0
	
	print("BattleScene показана, visible: ", visible)
	
	# Инициализируем героев и врагов
	initialize_characters()
	
	# Очищаем лог и обновляем UI
	battle_log.text = ""
	add_battle_log("[color=white]Бой начинается![/color]", 0.0)
	
	# Начинаем первый ход
	await get_tree().create_timer(1.0).timeout
	process_turn()

func initialize_characters():
	# Инициализируем героев
	heroes = []
	var hero_colors = ["blue", "red", "green"]
	for i in range(1, 4):  # 3 героя
		var hero = {
			"name": "Герой " + str(i),
			"sprite": get_node("BattleZone/HeroesContainer/Hero" + str(i) + "/HeroSprite" + str(i)),
			"hp_bar": get_node("BattleZone/HeroesContainer/Hero" + str(i) + "/HeroHPBar" + str(i)),
			"hp_label": get_node("BattleZone/HeroesContainer/Hero" + str(i) + "/HeroHP" + str(i)),
			"max_hp": 20,
			"current_hp": 20,
			"damage": randi_range(5, 10),
			"alive": true
		}
		
		# Устанавливаем цвет для героя (пока используем ColorRect)
		match i:
			1: hero["sprite"].modulate = Color.BLUE
			2: hero["sprite"].modulate = Color.RED
			3: hero["sprite"].modulate = Color.GREEN
		
		heroes.append(hero)
		update_character_ui(hero)
	
	# Инициализируем врагов (1-3 случайных)
	var enemy_count = randi_range(1, 3)
	enemies = []
	var enemy_colors = ["purple", "orange", "green"]
	for i in range(1, enemy_count + 1):
		var enemy = {
			"name": "Враг " + str(i),
			"sprite": get_node("BattleZone/EnemiesContainer/Enemy" + str(i) + "/EnemySprite" + str(i)),
			"hp_bar": get_node("BattleZone/EnemiesContainer/Enemy" + str(i) + "/EnemyHPBar" + str(i)),
			"hp_label": get_node("BattleZone/EnemiesContainer/Enemy" + str(i) + "/EnemyHP" + str(i)),
			"max_hp": randi_range(12, 18),
			"current_hp": 0,  # Будет установлено ниже
			"damage": randi_range(4, 8),
			"alive": true
		}
		enemy["current_hp"] = enemy["max_hp"]
		
		# Устанавливаем цвет для врага (пока используем ColorRect)
		match i:
			1: enemy["sprite"].modulate = Color(0.5, 0, 0.5)  # Фиолетовый
			2: enemy["sprite"].modulate = Color(0.8, 0.4, 0)  # Оранжевый
			3: enemy["sprite"].modulate = Color(0.2, 0.8, 0.2)  # Зеленый
		
		enemies.append(enemy)
		update_character_ui(enemy)
	
	# Скрываем неиспользуемых врагов
	for i in range(enemy_count + 1, 4):
		var enemy_node = get_node("BattleZone/EnemiesContainer/Enemy" + str(i))
		if enemy_node:
			enemy_node.visible = false

func process_turn():
	if not is_battle_active:
		return
	
	current_turn += 1
	
	# Ход героев
	await heroes_turn()
	
	# Проверяем, не закончился ли бой
	if check_battle_end():
		return
	
	# Ход врагов
	await enemies_turn()
	
	# Проверяем, не закончился ли бой
	if check_battle_end():
		return
	
	# Следующий ход
	await get_tree().create_timer(turn_delay).timeout
	process_turn()

func heroes_turn():
	var alive_heroes = get_alive_characters(heroes)
	if alive_heroes.size() == 0:
		return
	
	for hero in alive_heroes:
		if not is_battle_active:
			return
		
		var alive_enemies = get_alive_characters(enemies)
		if alive_enemies.size() == 0:
			return
		
		# Выбираем случайного врага
		var target = alive_enemies[randi() % alive_enemies.size()]
		
		# Атакуем
		await attack_character(hero, target, true)
		
		# Небольшая пауза между атаками героев
		await get_tree().create_timer(0.5).timeout

func enemies_turn():
	var alive_enemies = get_alive_characters(enemies)
	if alive_enemies.size() == 0:
		return
	
	for enemy in alive_enemies:
		if not is_battle_active:
			return
		
		var alive_heroes = get_alive_characters(heroes)
		if alive_heroes.size() == 0:
			return
		
		# Выбираем случайного героя
		var target = alive_heroes[randi() % alive_heroes.size()]
		
		# Атакуем
		await attack_character(enemy, target, false)
		
		# Небольшая пауза между атаками врагов
		await get_tree().create_timer(0.5).timeout

func attack_character(attacker, target, is_hero_attack):
	# Анимация атаки
	await attack_animation(attacker["sprite"])
	
	# Наносим урон
	var damage = attacker["damage"]
	target["current_hp"] = max(0, target["current_hp"] - damage)
	
	# Анимация получения урона
	await damage_animation(target["sprite"])
	
	# Обновляем UI
	update_character_ui(target)
	
	# Проверяем, не умер ли персонаж
	if target["current_hp"] <= 0:
		target["alive"] = false
		target["sprite"].modulate = Color.GRAY
	
	# Добавляем запись в лог
	var attacker_name = attacker["name"]
	var target_name = target["name"]
	var color = "[color=green]" if is_hero_attack else "[color=red]"
	var log_text = color + attacker_name + " атакует " + target_name + " на " + str(damage) + " урона![/color]"
	add_battle_log(log_text, 0.5)

func attack_animation(sprite):
	# Смещаем спрайт вперед
	var original_pos = sprite.position
	var tween = create_tween()
	tween.tween_property(sprite, "position", original_pos + Vector2(20, 0), attack_animation_duration / 2)
	tween.tween_property(sprite, "position", original_pos, attack_animation_duration / 2)
	await tween.finished

func damage_animation(sprite):
	# Красная вспышка при получении урона
	var original_modulate = sprite.modulate
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, damage_flash_duration / 2)
	tween.tween_property(sprite, "modulate", original_modulate, damage_flash_duration / 2)
	await tween.finished

func update_character_ui(character):
	# Обновляем полоску здоровья
	var hp_percentage = float(character["current_hp"]) / character["max_hp"] * 100
	character["hp_bar"].value = hp_percentage
	
	# Обновляем текст HP
	character["hp_label"].text = "HP: " + str(character["current_hp"]) + "/" + str(character["max_hp"])
	
	# Меняем цвет полоски здоровья в зависимости от HP
	if hp_percentage > 60:
		character["hp_bar"].modulate = Color.GREEN
	elif hp_percentage > 30:
		character["hp_bar"].modulate = Color.YELLOW
	else:
		character["hp_bar"].modulate = Color.RED

func get_alive_characters(characters):
	var alive = []
	for character in characters:
		if character["alive"]:
			alive.append(character)
	return alive

func check_battle_end():
	var alive_heroes = get_alive_characters(heroes)
	var alive_enemies = get_alive_characters(enemies)
	
	if alive_heroes.size() == 0:
		# Поражение
		add_battle_log("[color=red]Все герои погибли![/color]", 0.5)
		end_battle(false)
		return true
	elif alive_enemies.size() == 0:
		# Победа
		add_battle_log("[color=gold]Все враги побеждены![/color]", 0.5)
		end_battle(true)
		return true
	
	return false

func end_battle(victory):
	is_battle_active = false
	
	# Показываем результат
	result_label.text = "ПОБЕДА!" if victory else "ПОРАЖЕНИЕ!"
	result_label.visible = true
	
	# Ждем 2 секунды
	await get_tree().create_timer(2.0).timeout
	
	# Закрываем сцену
	close_battle_scene()

func add_battle_log(text, delay = 0.0):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	battle_log.append_text(text + "\n")

func close_battle_scene():
	# Определяем результат боя
	var alive_heroes = get_alive_characters(heroes)
	var victory = alive_heroes.size() > 0
	
	# Эмитим сигнал
	emit_signal("battle_finished", victory)
	
	# Удаляем сцену
	queue_free() 
