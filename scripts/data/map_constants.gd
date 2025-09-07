class_name MapConstants
extends RefCounted

# Типы событий
enum EventType {
	SAFE,    # Безопасная зона
	BATTLE,  # Бой
	SHOP,    # Магазин
	RANDOM,  # Случайное событие
	EMPTY    # Пустая комната
}

# Настройки внешнего вида
const COLORS = {
	EventType.SAFE: Color(1.0, 0.9, 0.2),    # Желтый
	EventType.BATTLE: Color(0.9, 0.2, 0.2),  # Красный
	EventType.SHOP: Color(0.2, 0.5, 0.9),    # Синий
	EventType.RANDOM: Color(0.7, 0.3, 0.9),  # Фиолетовый
	EventType.EMPTY: Color(0.3, 0.8, 0.3)    # Зеленый
}

const ICONS = {
	EventType.SAFE: "🏠",
	EventType.BATTLE: "⚔️",
	EventType.SHOP: "🛒",
	EventType.RANDOM: "❓",
	EventType.EMPTY: "🌿"
}