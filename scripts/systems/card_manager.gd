extends Node2D

class_name CardManager

@onready var screen_size = get_viewport_rect().size
@onready var hand_reference: Hand = $"../PlayerHand"
@onready var opponent_hand_reference: OpponentHand = $"../OpponentHand"
@onready var deck_reference: Deck = $"../Deck"
@onready var dutch_manager: DutchManager = $".."

const CARD_COLLISION_MASK: int = 1
const SLOT_COLLISION_MASK: int = 2

const CARD_SIZE: float = 1.3
const HIGHLIGHTED_CARD_SIZE: float = 1.5

var card_being_dragged : Card
var is_hovering_a_card: bool = false
var played_this_turn: bool = false

func _ready() -> void:
	$"../InputManager".connect("left_mouse_released", on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = mouse_pos
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
											  clamp(mouse_pos.y, 0, screen_size.y))

func connect_card_signals(card: Card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func highlight_card(card: Card, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(HIGHLIGHTED_CARD_SIZE, HIGHLIGHTED_CARD_SIZE)
		card.z_index = 2 
	else:
		card.scale = Vector2(CARD_SIZE, CARD_SIZE)
		if card.is_in_card_slot:
			card.z_index = 0 
		else:
			card.z_index = 1
	
func on_hovered_over_card(card: Card) -> void:
	if !is_hovering_a_card and not card.is_in_card_slot:
		is_hovering_a_card = true
		highlight_card(card, true)
	
func on_hovered_off_card(card: Card) -> void:
	highlight_card(card, false)
	var new_card_hovered: Card = raycast_check_for_card()
	if new_card_hovered and not new_card_hovered.is_in_card_slot:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_a_card = false

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = CARD_COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0: 
		return get_card_with_highest_z_index(result)
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = SLOT_COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0: 
		return result[0].collider.get_parent()
	return null
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
	
func start_drag(card: Card) -> void:
	if not card.is_in_card_slot:
		card_being_dragged = card
		card.scale = Vector2(HIGHLIGHTED_CARD_SIZE, HIGHLIGHTED_CARD_SIZE)
		var card_slot_found = raycast_check_for_card_slot()
		if card_slot_found:
			card_slot_found.card_in_slot = null

func finish_drag() -> void:
	card_being_dragged.scale = Vector2(CARD_SIZE, CARD_SIZE)
	var card_slot_found: CardSlot = raycast_check_for_card_slot()
	var move_is_valid: bool = false
	var is_cutting: bool = false
	if card_slot_found:
		if card_slot_found.card_in_slot:
			if card_slot_found.card_in_slot.rank == card_being_dragged.rank:
				is_cutting = true
		if is_cutting:
			move_is_valid = true
		elif Global.turn == TurnType.TurnType.PLAYER and \
			Global.drawn_this_turn and \
			not Global.has_played_card:
			move_is_valid = true
	if move_is_valid:
		if card_slot_found.card_in_slot:
			card_slot_found.get_node("Sprite2D").texture = card_slot_found.card_in_slot.get_node("CardFront").texture
			card_slot_found.card_in_slot.queue_free()
		hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.reparent(card_slot_found)
		card_being_dragged.position = Vector2.ZERO
		card_slot_found.card_in_slot = card_being_dragged 
		card_being_dragged.is_in_card_slot = true
		card_being_dragged.get_node("AnimationPlayer").play("flip_card_up")
		highlight_card(card_being_dragged, false)
		if not is_cutting:
			Global.set_played_card()
		apply_card_effect(card_being_dragged)
	else:
		hand_reference.add_card_to_hand(card_being_dragged, Global.DEFAULT_CARD_SPEED)
	card_being_dragged = null

func apply_card_effect(card: Card) -> void:
	match card.rank: 
		CardEnum.Rank.QUEEN:
			print("Poder da Rainha")
			Global.set_game_state(GameState.GameState.POWER_QUEEN)
		CardEnum.Rank.JACK:
			print("Poder do Jack")
			Global.set_game_state(GameState.GameState.POWER_JACK_STEP_1)
		CardEnum.Rank.KING:
			if Global.turn == TurnType.TurnType.PLAYER:
				deck_reference.draw_card(true)

func place_opponent_card(card: Card) -> void:
	var card_slot: CardSlot = $"../CardSlot"
	if card_slot.card_in_slot:
		card_slot.get_node("Sprite2D").texture = card_slot.card_in_slot.get_node("CardFront").texture
		card_slot.card_in_slot.queue_free()
	opponent_hand_reference.remove_card_from_hand(card)
	var old_global_pos = card.global_position
	card.reparent(card_slot)
	card.global_position = old_global_pos
	card.z_index = 10
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position", Vector2.ZERO, Global.DEFAULT_CARD_SPEED)
	await tween.finished
	card.get_node("AnimationPlayer").play("flip_card_up")
	await get_tree().create_timer(1).timeout
	card_slot.card_in_slot = card 
	card.is_in_card_slot = true
	highlight_card(card, false)
	
func swap_cards(card1: Card, card2: Card):
	var hand1 = null
	var hand2 = null
	if card1 in hand_reference.hand: hand1 = hand_reference
	elif card1 in opponent_hand_reference.hand: hand1 = opponent_hand_reference
	if card2 in hand_reference.hand: hand2 = hand_reference
	elif card2 in opponent_hand_reference.hand: hand2 = opponent_hand_reference
	
	if hand1 and hand2:
		var idx1 = hand1.hand.find(card1)
		var idx2 = hand2.hand.find(card2)
		
		hand1.hand[idx1] = card2
		hand2.hand[idx2] = card1
		
		var parent1 = card1.get_parent()
		var parent2 = card2.get_parent()
		
		var pos1 = card1.global_position
		var pos2 = card2.global_position
		
		card1.reparent(parent2)
		card2.reparent(parent1)
		
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(card1, "global_position", pos2, 0.5)
		tween.tween_property(card2, "global_position", pos1, 0.5)
		
		await tween.finished
		
		hand1.update_hand_positions(0.2)
		hand2.update_hand_positions(0.2)

func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag()
