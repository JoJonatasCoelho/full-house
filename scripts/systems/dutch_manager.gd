extends Node

class_name DutchManager

@onready var battle_time: Timer = $Timer
@onready var end_turn_button: Button = $Control/EndTurn
@onready var dutch_button: Button = $Control/DutchButton
@onready var winner_label: Label = $Control/Label
@onready var player_hand: Hand = $PlayerHand
@onready var opponent_hand: OpponentHand = $OpponentHand
@onready var card_manager: CardManager = $CardManager
@onready var opponent_played_card: bool = false

var cards_peeked_start: int = 0
var jack_selection_1: Card = null

func _ready() -> void:
	battle_time.one_shot = true
	battle_time.wait_time = 1.0
	end_turn_button.visible = false
	dutch_button.disabled = true
	Global.game_state = GameState.GameState.WAITING_START_PEEK	

func _on_end_turn_pressed() -> void:
	if Global.turn == TurnType.TurnType.PLAYER:
		finish_player_turn()
	
func finish_player_turn() -> void:
	Global.toggle_turn_type()
	opponent_turn()
	
func opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	dutch_button.disabled = true
	Global.reset_played_card()     
	Global.reset_drawn_this_turn()
	$Deck.draw_card(true)
	battle_time.start()
	await battle_time.timeout
	opponent_decision()
	if opponent_hand.hand.size() > 0:
		var card_to_play = opponent_hand.hand.pick_random() 
		await $CardManager.place_opponent_card(card_to_play)
	if opponent_hand.hand.size() == 0:
		declare_dutch()
	else:
		end_opponent_turn()
	
func opponent_decision() -> void:
	pass
	
func end_opponent_turn() -> void:
	end_turn_button.disabled = false
	end_turn_button.visible = true
	dutch_button.disabled = false
	Global.toggle_turn_type() 
	Global.reset_played_card()
	Global.reset_drawn_this_turn()

func declare_dutch() -> void:
	Global.announce_dutch()
	battle_time.stop()
	end_turn_button.disabled = true
	dutch_button.disabled = true
	
	$InputManager.set_process_input(false)
	
	reveal_oppenent_hand()
	
	opponent_hand.recalculate_hand_sum() 
	var opponent_score = opponent_hand.hand_sum
	var player_score = player_hand.hand_sum
	
	print("Player: ", player_score, " vs Oponente: ", opponent_score)
	
	if player_score < opponent_score:
		game_over("VITÓRIA!", Color.GREEN)
	elif player_score > opponent_score:
		game_over("DERROTA...", Color.RED)
	else:
		game_over("EMPATE!", Color.YELLOW)
	
func game_over(message: String, color: Color) -> void:
	if winner_label:
		winner_label.text = message + "\nPlayer: " + str(player_hand.hand_sum) + \
		" | CPU: " + str(opponent_hand.hand_sum)
		winner_label.modulate = color
		winner_label.visible = true

func _on_dutch_button_pressed() -> void:
	if Global.turn == TurnType.TurnType.PLAYER:
		declare_dutch()

func reveal_oppenent_hand() -> void:
	for card in opponent_hand.hand:
		card.get_node("AnimationPlayer").play("flip_card_up")

func handle_card_click(card: Card):
	match Global.game_state:
		GameState.GameState.WAITING_START_PEEK:
			if card in player_hand.hand and cards_peeked_start < 2:
				card.peek_card()
				cards_peeked_start += 1
				if cards_peeked_start >= 2:
					await get_tree().create_timer(2.0).timeout
					start_game_officially()
					
		GameState.GameState.POWER_QUEEN:
			if card in player_hand.hand:
				card.peek_card(3.0)
				finish_power_action()
				
		GameState.GameState.POWER_JACK_STEP_1:
			jack_selection_1 = card
			card.modulate = Color(0.5, 0.5, 1)
			Global.set_game_state(GameState.GameState.POWER_JACK_STEP_2)
		GameState.GameState.POWER_JACK_STEP_2:
			if card != jack_selection_1:
				perform_jack_swap(jack_selection_1, card)

func start_game_officially() -> void:
	Global.set_game_state(GameState.GameState.NORMAL_PLAY)
	end_turn_button.visible = true
	
func finish_power_action() -> void:
	Global.set_game_state(GameState.GameState.NORMAL_PLAY)
	finish_player_turn()
	
func perform_jack_swap(card1: Card, card2: Card):
	card_manager.swap_cards(card1, card2)
	card1.modulate = Color.WHITE
	jack_selection_1 = null
	finish_power_action()
