extends Node

class_name Deck

const CARD_SCENE_PATH: String = "res://scenes/interactables/card.tscn"
const INITIAL_HAND_SIZE: int = 4

var deck: Array[Card] = []

func _ready() -> void:
	generate_standard_deck()
	shuffle_deck()
	for i in range(INITIAL_HAND_SIZE):
		draw_card(false, true)
		Global.reset_drawn_this_turn()
		draw_card(true)
		Global.reset_drawn_this_turn()
	Global.reset_drawn_this_turn()
	
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

func draw_card(opponent_turn: bool, first_draw: bool = false):
	Global.set_drawn_this_turn()
	var card_drawn = deck[0]
	deck.erase(card_drawn)
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card: Card = card_scene.instantiate()
	var card_image_path = str("res://assets/cards/"+card_drawn.get_id()+".png")
	new_card.get_node("CardFront").texture = load(card_image_path)
	new_card.name = card_drawn.get_id()
	new_card.rank = card_drawn.rank
	new_card.suit = card_drawn.suit
	$"../CardManager".add_child(new_card)
	if not opponent_turn:
		$"../PlayerHand".add_card_to_hand(new_card, Global.DEFAULT_CARD_SPEED)
		if Global.game_state == GameState.GameState.NORMAL_PLAY and not first_draw:
			new_card.peek_card(2.0)
	else:
		#var opponent_card_area: Area2D = new_card.get_node("Area2D")
		#new_card.remove_child(opponent_card_area)
		$"../OpponentHand".add_card_to_hand(new_card, Global.DEFAULT_CARD_SPEED)
