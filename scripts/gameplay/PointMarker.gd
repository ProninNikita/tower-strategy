extends Node2D

enum PointType {
	START,
	NORMAL,
	CURRENT,
	VISITED
}

@export var point_type: PointType = PointType.NORMAL
@export var texture: Texture2D

var sprite: Sprite2D
var animation_player: AnimationPlayer

func _ready():
	sprite = $Sprite2D
	animation_player = $AnimationPlayer
	update_appearance()

func set_point_type(new_type: PointType):
	point_type = new_type
	update_appearance()

func update_appearance():
	if not sprite:
		return
	
	# Останавливаем анимацию мигания
	animation_player.stop()
	
	match point_type:
		PointType.START:
			set_color(Color.RED)
			sprite.scale = Vector2(1.2, 1.2)  # 24x24
		PointType.NORMAL:
			set_color(Color.GREEN)
			sprite.scale = Vector2(1.0, 1.0)  # 20x20
		PointType.CURRENT:
			set_color(Color.YELLOW)
			sprite.scale = Vector2(1.0, 1.0)  # 20x20
			animation_player.play("blink")
		PointType.VISITED:
			set_color(Color.GRAY)
			sprite.scale = Vector2(1.0, 1.0)  # 20x20

func set_color(color: Color):
	if texture:
		# Если есть текстура, используем modulate для изменения цвета
		sprite.texture = texture
		sprite.modulate = color
	else:
		# Если нет текстуры, создаем ColorRect
		if sprite.get_child_count() > 0:
			sprite.get_child(0).queue_free()
		
		var color_rect = ColorRect.new()
		color_rect.size = Vector2(20, 20)
		color_rect.position = Vector2(-10, -10)
		color_rect.color = color
		sprite.add_child(color_rect) 