extends Node

const DEFAULT_CARD_SPEED: float = 1.0

func animate_card_to_position(card: Card, new_position: Vector2, speed: float):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
