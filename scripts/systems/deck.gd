extends Node

class_name Deck

var deck:Array[Card]

func shuffle_deck() -> void:
	pass

func make_card() -> Card:
	var new_card: Card  = _get_random_card()
	deck.erase(new_card)
	return new_card

func _get_random_card() -> Card: 
	return Card()
