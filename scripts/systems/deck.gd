extends Node

class_name Deck

const CARD_SCENE_PATH: String = "res://scenes/interactables/card.tscn"
const CARD_DRAW_SPEED: float = 0.5

var deck = ["1","2","3","4","5","6","7"]

func draw_card():
	var card_drawn = deck[0]
	deck.erase(card_drawn)
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
