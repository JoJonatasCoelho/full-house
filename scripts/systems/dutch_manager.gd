extends Node

class_name DutchManager

@onready var battle_time: Timer = $Timer
@onready var result_image: TextureRect = $Control/ResultImage
@onready var end_turn_button: Button = $Control/EndTurn
@onready var dutch_button: Button = $Control/DutchButton
@onready var winner_label: Label = $Control/Label
@onready var player_hand: Hand = $PlayerHand
@onready var opponent_hand: OpponentHand = $OpponentHand
@onready var card_manager: CardManager = $CardManager
@onready var opponent_played_card: bool = false

@export_category("Level Transition")
@export_file("*.ogv") var victory_video_path: String 
@export_file("*.tscn") var next_level_scene: String
@export var opponent: String
@export var animated_sprite: AnimatedSprite2D

var cards_peeked_start: int = 0
var jack_selection_1: Card = null

const TEX_VICTORY: Texture2D = preload("res://assets/final_game/victory.png")
const TEX_DEFEAT: Texture2D = preload("res://assets/final_game/defeat.png")
const TEX_DRAW: Texture = preload("res://assets/buttons/draw.png")

func _ready() -> void:
	print(get_viewport().size.y)
	animated_sprite.play("stand")
	battle_time.one_shot = true
	battle_time.wait_time = 1.0
	end_turn_button.visible = false
	dutch_button.disabled = true
	result_image.visible = false
	SaveManager.save_data.current_scene = get_tree().current_scene.scene_file_path
	SaveManager._save()

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
	if animated_sprite:
		animated_sprite.play("draw")
		await animated_sprite.animation_finished
		if animated_sprite.sprite_frames.has_animation("drop"):
			animated_sprite.play("drop")
			await animated_sprite.animation_finished
		$Deck.draw_card(true)
		animated_sprite.play("stand")
	else:
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
		show_result(TEX_VICTORY, true) 
	elif player_score > opponent_score:
		show_result(TEX_DEFEAT, false)
	else:
		show_result(TEX_DRAW, false) 

func show_result(tex: Texture2D, is_victory: bool) -> void:
	result_image.texture = tex
	result_image.visible = true
	
	if is_victory:
		process_victory_sequence()
	else:
		process_defeat_sequence()
	
func process_victory_sequence() -> void:
	if next_level_scene != "":
		SaveManager.save_data.current_scene = next_level_scene
		SaveManager._save()
	
	await get_tree().create_timer(4.0).timeout
	
	if victory_video_path != "" and next_level_scene != "":
		Global.play_cutscene(victory_video_path, next_level_scene)
	elif next_level_scene != "":
			get_tree().change_scene_to_file(next_level_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/levels/menu.tscn")
	
func process_defeat_sequence() -> void:
	await get_tree().create_timer(3.0).timeout
	
	if SaveManager.has_method("load_game_and_switch_scene"):
		SaveManager.load_game_and_switch_scene()
	else:
		get_tree().reload_current_scene()
		
func game_over():
	pass
	
func result_game(message: String, color: Color) -> void:
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
