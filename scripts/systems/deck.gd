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
	var new_card: Card = card_scene.instantiate()
	var card_image_path = str("res://assets/cards/"+card_drawn.get_id()+".png")
	new_card.get_node("Sprite2D").texture = load(card_image_path)
	new_card.name = card_drawn.get_id()
	new_card.rank = card_drawn.rank
	new_card.suit = card_drawn.suit
	$"../CardManager".add_child(new_card)
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
