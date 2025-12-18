extends Node2D

class_name Card

signal hovered
signal hovered_off

var starting_position: Vector2

@export var suit: CardEnum.Suit
@export var rank: CardEnum.Rank

func get_id() -> String:
	return str(CardEnum.Rank.keys()[rank - 1]) + "_of_" + str(CardEnum.Suit.keys()[suit])

func _ready() -> void:
	var manager: CardManager =  get_parent()
	manager.connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
