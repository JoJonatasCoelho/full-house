extends Node

class_name Hand

@onready var center_screen_x = get_viewport().size.x / 2
@onready var hand_y_position = get_viewport().size.y / 1.2
@onready var card_width = center_screen_x / 6

var hand:Array[Card]
var hand_sum:int
		
func add_card_to_hand(card: Card, speed: float):
	if card not in hand:
		hand.insert(0, card)
		update_hand_positions(Global.DEFAULT_CARD_SPEED)
		recalculate_hand_sum()
	else:
		Global.animate_card_to_position(card, card.starting_position, Global.DEFAULT_CARD_SPEED)

func remove_card_from_hand(card: Card):
	if card in hand:
		hand.erase(card)
		update_hand_positions(Global.DEFAULT_CARD_SPEED)
		recalculate_hand_sum()

func update_hand_positions(speed):
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = hand[i]
		print(card, i)
		card.starting_position = new_position
		Global.animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(idx: int):
	var total_width = (hand.size() - 1) * card_width
	var x_offset = center_screen_x + idx * card_width - total_width / 2
	return x_offset
	
func recalculate_hand_sum():
	hand_sum = 0
	for card in hand:
		if card.rank == CardEnum.Rank.KING and \
				(card.suit == CardEnum.Suit.CLUBS or card.suit == CardEnum.Suit.SPADES):
			hand_sum += 0
		else: hand_sum += 10 if card.rank > 10 else card.rank
	#print(hand_sum)
