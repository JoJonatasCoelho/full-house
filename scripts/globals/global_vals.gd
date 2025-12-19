extends Node

const DEFAULT_CARD_SPEED: float = 1.0
var drawn_this_turn: bool = false
var has_played_card: bool = false
var turn: TurnType.TurnType = TurnType.TurnType.PLAYER

func animate_card_to_position(card: Card, new_position: Vector2, speed: float):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	
func reset_drawn_this_turn():
	drawn_this_turn = false
	
func set_drawn_this_turn():
	drawn_this_turn = true
	
func reset_played_card():
	has_played_card = false
	
func set_played_card():
	has_played_card = true 

func toggle_turn_type():
	turn = TurnType.TurnType.OPPONENT if turn == TurnType.TurnType.PLAYER else TurnType.TurnType.PLAYER
