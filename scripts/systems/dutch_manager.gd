extends Node

class_name DutchManager

@onready var battle_time: Timer = $Timer
@onready var end_turn_button: Button = $EndTurn

@onready var oppnent_hand: OpponentHand = $OpponentHand

@onready var opponent_played_card: bool = false

func _ready() -> void:
	battle_time.one_shot = true
	battle_time.wait_time = 1

func _on_end_turn_pressed() -> void:
	if Global.drawn_this_turn:
		Global.toggle_turn_type()
		opponent_turn()
	
func opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	Global.reset_played_card()	
	$Deck.draw_card(true)
	opponent_decision()
	battle_time.start()
	await battle_time.timeout
	$CardManager.place_opponent_card(oppnent_hand.hand[randi_range(0, 4)])
	if oppnent_hand.hand.size() == 0:
		declare_dutch()
	end_opponent_turn()
	
func opponent_decision() -> void:
	pass
	
func end_opponent_turn() -> void:
	end_turn_button.disabled = false
	end_turn_button.visible = true
	opponent_played_card = true
	Global.toggle_turn_type()
	
	#resetar aqui a variável de puxada nesse turno

func declare_dutch() -> void:
	pass
