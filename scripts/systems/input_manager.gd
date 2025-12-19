extends Node2D

signal left_mouse_clicked
signal left_mouse_released

const CARD_COLLISION_MASK: int = 1
const DECK_COLLISION_MASK: int = 4

@onready var card_manager_reference: CardManager = $"../CardManager"
@onready var dutch_manager: DutchManager = $".."
@onready var deck_reference: Deck = $"../Deck"
@onready var opponent_hand: OpponentHand = $"../OpponentHand"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index  == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_released")
			
func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0: 
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == CARD_COLLISION_MASK:
			var card_found = result[0].collider.get_parent()
			if card_found:
				var is_opponent_card = card_found in opponent_hand.hand
				if is_opponent_card:
					if Global.game_state == GameState.GameState.POWER_JACK_STEP_1 or \
						Global.game_state == GameState.GameState.POWER_JACK_STEP_2:
						dutch_manager.handle_card_click(card_found)
					else:
						pass
				else:
					if Global.game_state == GameState.GameState.NORMAL_PLAY:
						card_manager_reference.start_drag(card_found)
					else:
						dutch_manager.handle_card_click(card_found)
		elif result_collision_mask == DECK_COLLISION_MASK:
			if Global.turn == TurnType.TurnType.PLAYER and not Global.drawn_this_turn:
				deck_reference.draw_card(false)
