extends Area2D

# Сигнал клика по точке
signal point_clicked(point)

# Подключаем константы
const Constants = preload("res://scripts/data/map_constants.gd")

# Свойства точки
var event_type: int = Constants.EventType.EMPTY
var is_branch_point: bool = false
var point_id: int = -1

# Узлы
@onready var icon: Label = $Icon
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Настраиваем размер области клика
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	collision_shape.shape = shape
	
	# Включаем обработку событий
	input_pickable = true
	
	# Обновляем внешний вид
	update_appearance()

func set_event_type(type: int) -> void:
	"""Устанавливает тип события и обновляет внешний вид"""
	event_type = type
	update_appearance()

func update_appearance() -> void:
	"""Обновляет внешний вид точки в соответствии с типом события"""
	if not is_node_ready():
		await ready
	
	# Устанавливаем иконку
	icon.text = Constants.ICONS[event_type]
	
	# Устанавливаем цвет
	modulate = Constants.COLORS[event_type]

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	"""Обрабатывает клик по точке"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("point_clicked", self)

func _on_mouse_entered() -> void:
	"""Обрабатывает наведение мыши"""
	# Подсветка при наведении
	modulate = Constants.COLORS[event_type].lightened(0.2)

func _on_mouse_exited() -> void:
	"""Обрабатывает уход мыши"""
	# Возвращаем обычный цвет
	modulate = Constants.COLORS[event_type]

func show_click_feedback() -> void:
	"""Показывает анимацию клика"""
	# Кратковременная подсветка белым
	var original_color = modulate
	modulate = Color.WHITE
	
	get_tree().create_timer(0.1).timeout.connect(func():
		modulate = original_color
	)
