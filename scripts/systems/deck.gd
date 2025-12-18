extends Node

class_name Deck

const CARD_SCENE_PATH: String = "res://scenes/interactables/card.tscn"
const CARD_DRAW_SPEED: float = 0.5

var deck: Array[Card] = []

func _ready() -> void:
	generate_standard_deck()
	shuffle_deck()
	
func generate_standard_deck():
	deck.clear()
	for s in CardEnum.Suit.values():
		for r in range(1, 14):
			var new_card: Card = Card.new()
			new_card.rank = r as CardEnum.Rank
			new_card.suit = s as CardEnum.Suit
			deck.append(new_card)

func  shuffle_deck():
	deck.shuffle()

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
	print(card_drawn.get_id())
