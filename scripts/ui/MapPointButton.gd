extends Button

# Сигнал для клика по точке
signal point_clicked(point_ref)

# Свойства точки
var point_id: int = -1
var event_type: int = 0
var is_key_point: bool = false
var is_visited: bool = false
var is_current: bool = false

# Константы для внешнего вида
const EVENT_ICONS = {
	0: "🏠",  # SAFE_ZONE
	1: "⚔️",  # BATTLE
	2: "🛒",  # MERCHANT
	3: "❓",  # RANDOM
	4: "🌿"   # EMPTY
}

const COLORS = {
	0: Color(1.0, 0.9, 0.2, 0.9),    # SAFE_ZONE (приглушенный желтый)
	1: Color(0.9, 0.2, 0.2, 0.9),    # BATTLE (приглушенный красный)
	2: Color(0.2, 0.5, 0.9, 0.9),    # MERCHANT (приглушенный синий)
	3: Color(0.7, 0.3, 0.9, 0.9),    # RANDOM (приглушенный фиолетовый)
	4: Color(0.3, 0.8, 0.3, 0.9)     # EMPTY (приглушенный зеленый)
}

const HOVER_LIGHTEN = 0.2  # Насколько осветлять при наведении
const PRESS_DARKEN = 0.3   # Насколько затемнять при нажатии

# Ссылки на дочерние узлы
@onready var icon_label: Label = $Icon

func _ready():
	print("=== ИНИЦИАЛИЗАЦИЯ BUTTON ТОЧКИ ", point_id, " ===")
	
	# Настраиваем Button
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)
	flat = false  # Показываем рамку кнопки
	focus_mode = Control.FOCUS_NONE  # Отключаем фокус
	
	# Подключаем сигнал клика
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Обновляем внешний вид
	update_appearance()
	
	print("Button точка ", point_id, " (ключевая: ", is_key_point, ") готова к кликам на позиции ", position)
	print("================================")

func _on_button_pressed():
	"""Обрабатывает клик по кнопке"""
	print("=== BUTTON КЛИК ТОЧКА ", point_id, " ===")
	print("Ключевая: ", is_key_point, " Посещена: ", is_visited, " Disabled: ", disabled)
	
	# Проверяем, что это ключевая точка и кнопка не отключена
	if is_key_point and not is_visited and not disabled:
		print("✅ Эмитим сигнал для точки ", point_id)
		show_click_feedback()
		emit_signal("point_clicked", self)
	else:
		print("❌ Точка не подходит для клика: ключевая=", is_key_point, " посещена=", is_visited, " отключена=", disabled)
	print("================================")

func _on_mouse_entered():
	"""Обрабатывает наведение мыши"""
	print("Мышь вошла в Button точку ", point_id, " (ключевая: ", is_key_point, ")")
	if is_key_point and not is_visited:
		# Получаем текущий стиль
		var current_style = get_theme_stylebox("normal") as StyleBoxFlat
		if current_style:
			# Создаем стиль для наведения
			var hover_style = current_style.duplicate()
			hover_style.bg_color = current_style.bg_color.lightened(HOVER_LIGHTEN)
			hover_style.border_color = current_style.border_color.lightened(HOVER_LIGHTEN)
			add_theme_stylebox_override("hover", hover_style)
			print("Подсветка включена для точки ", point_id)

func _on_mouse_exited():
	"""Обрабатывает уход мыши"""
	print("Мышь вышла из Button точки ", point_id)
	update_appearance()

func show_click_feedback():
	"""Показывает анимацию клика"""
	# Получаем текущий стиль
	var current_style = get_theme_stylebox("normal") as StyleBoxFlat
	if current_style:
		# Создаем стиль для клика
		var click_style = current_style.duplicate()
		click_style.bg_color = Color.WHITE
		click_style.border_color = Color.WHITE
		add_theme_stylebox_override("pressed", click_style)
		
		# Возвращаем исходный цвет через 0.1 секунды
		get_tree().create_timer(0.1).timeout.connect(func():
			update_appearance()
		)

func update_appearance():
	"""Обновляет внешний вид точки"""
	if not icon_label:
		return
	
	# Создаем базовый стиль
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	
	# Определяем цвета в зависимости от состояния
	var base_color = COLORS.get(event_type, Color.WHITE)
	if is_visited:
		style.bg_color = Color.GRAY
		style.border_color = Color.DARK_GRAY
	elif is_current:
		style.bg_color = Color.ORANGE
		style.border_color = Color.DARK_ORANGE
	else:
		style.bg_color = base_color
		style.border_color = base_color.darkened(0.2)
	
	# Применяем стиль ко всем состояниям
	add_theme_stylebox_override("normal", style)
	
	# Создаем стиль для наведения
	var hover_style = style.duplicate()
	hover_style.bg_color = style.bg_color.lightened(HOVER_LIGHTEN)
	hover_style.border_color = style.border_color.lightened(HOVER_LIGHTEN)
	add_theme_stylebox_override("hover", hover_style)
	
	# Создаем стиль для нажатия
	var pressed_style = style.duplicate()
	pressed_style.bg_color = style.bg_color.darkened(PRESS_DARKEN)
	pressed_style.border_color = style.border_color.darkened(PRESS_DARKEN)
	add_theme_stylebox_override("pressed", pressed_style)
	
	# Создаем стиль для отключенного состояния
	var disabled_style = style.duplicate()
	disabled_style.bg_color = style.bg_color.darkened(0.5)
	disabled_style.border_color = style.border_color.darkened(0.5)
	add_theme_stylebox_override("disabled", disabled_style)
	
	# Устанавливаем иконку
	icon_label.text = EVENT_ICONS.get(event_type, "?")
	
	# Отключаем кнопку если не ключевая или уже посещена
	disabled = not is_key_point or is_visited
	
	print("Обновлен внешний вид кнопки ", point_id, ": цвет=", base_color, " посещена=", is_visited, " ключевая=", is_key_point)

func set_visited(visited: bool):
	"""Устанавливает состояние посещения"""
	is_visited = visited
	update_appearance()

func set_current(current: bool):
	"""Устанавливает состояние текущей точки"""
	is_current = current
	update_appearance()

func disable_click():
	"""Отключает клики по точке"""
	disabled = true

func enable_click():
	"""Включает клики по точке"""
	disabled = false

func get_event_type_name() -> String:
	"""Возвращает название типа события"""
	var names = ["Безопасная зона", "Бой", "Торговец", "Случайное", "Пустая комната"]
	return names[event_type] if event_type < names.size() else "Неизвестно" 
