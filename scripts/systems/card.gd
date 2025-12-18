extends Node2D

class_name Card

signal hovered
signal hovered_off

var suit = CardEnum.Suits.Hearts
var type = CardEnum.Types.Number
var value:int = 1

func _ready() -> void:
	var manager: CardManager =  get_parent()
	manager.connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
