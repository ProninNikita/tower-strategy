extends Button

@export var button_type: String = ""

var original_scale: Vector2
var tween: Tween

func _ready():
	original_scale = scale
	pressed.connect(_on_button_pressed)
	
	# Настройка стилей для мобильных устройств
	custom_minimum_size = Vector2(80, 80)
	
	# Добавляем тень для лучшей читаемости
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_font_size_override("font_size", 16)

func _on_button_pressed():
	# Анимация нажатия
	animate_press()
	
	# Вибрация на мобильных устройствах
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
	
	# Обработка различных типов кнопок
	match button_type:
		"tower":
			_handle_tower_press()
		"portal":
			_handle_portal_press()
		"mansion":
			_handle_mansion_press()

func animate_press():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	# Уменьшение размера при нажатии
	tween.tween_property(self, "scale", original_scale * 0.9, 0.1)
	
	# Возврат к исходному размеру
	tween.tween_property(self, "scale", original_scale, 0.1).set_delay(0.1)
	
	# Добавляем легкое свечение
	var icon = get_node_or_null("PortalIcon")
	if not icon:
		icon = get_node_or_null("TowerIcon")
	if not icon:
		icon = get_node_or_null("MansionIcon")
	
	if icon:
		var original_color = icon.color
		tween.tween_property(icon, "color", original_color.lightened(0.3), 0.1)
		tween.tween_property(icon, "color", original_color, 0.1).set_delay(0.1)

func _handle_tower_press():
	print("Башня подземелий нажата!")
	# Здесь будет логика запуска подземелья
	# Можно добавить диалог подтверждения "Начать забег?"
	show_confirmation_dialog("Начать забег в подземелье?")

func _handle_portal_press():
	print("Портал героев нажат!")
	# Здесь будет логика открытия меню призыва героев
	# Можно добавить проверку количества доступных призывов
	var summon_count = get_node("SummonCount").text
	print("Доступно призывов: ", summon_count)

func _handle_mansion_press():
	print("Особняк героев нажат!")
	# Здесь будет логика открытия ростра героев
	var hero_count = get_node("HeroCount").text
	print("Всего героев: ", hero_count)

func show_confirmation_dialog(message: String):
	# Простая реализация диалога подтверждения
	# В реальном проекте здесь будет полноценный UI диалог
	print("Диалог: ", message)
	# Здесь можно добавить логику показа диалога 