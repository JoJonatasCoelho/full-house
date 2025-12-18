extends Node

class_name Hand

const DEFAULT_CARD_SPEED: float = 0.5

@onready var center_screen_x = get_viewport().size.x / 2
@onready var hand_y_position = get_viewport().size.y / 1.2
@onready var card_width = center_screen_x / 6

var hand:Array[Card]
var hand_sum:int
		
func add_card_to_hand(card: Card, speed: float):
	if card not in hand:
		hand.insert(0, card)
		update_hand_positions(DEFAULT_CARD_SPEED)
		recalculate_hand_sum()
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_SPEED)

func remove_card_from_hand(card: Card):
	if card in hand:
		hand.erase(card)
		update_hand_positions(DEFAULT_CARD_SPEED)

func update_hand_positions(speed):
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(idx: int):
	var total_width = (hand.size() - 1) * card_width
	var x_offset = center_screen_x + idx * card_width - total_width / 2
	return x_offset
	
func recalculate_hand_sum():
	hand_sum = 0
	for card in hand:
		hand_sum+=card.rank
		
func animate_card_to_position(card: Card, new_position: Vector2, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
