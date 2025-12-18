extends Node

class_name Hand


var drawed: Card
var hand:Array[Card]
var handSum:int

@export var deck: Deck

func get_card() -> Card:
	drawed = deck.make_card()
	choose_card(drawed)
	return drawed
		
func choose_card(choosed_card: Card) -> void:
	if choosed_card in hand:
		hand.erase(choosed_card)
		hand.append(drawed)
	drawed = null
	recalculate_hand_sum()
	
func recalculate_hand_sum():
	handSum = 0
	for card in hand:
		handSum+=card.value
