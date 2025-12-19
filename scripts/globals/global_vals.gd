extends Node

const DEFAULT_CARD_SPEED: float = 1.0
var drawn_this_turn: bool = false
var has_played_card: bool = false
var turn: TurnType.TurnType = TurnType.TurnType.PLAYER
var dutched: bool = false
var game_state: GameState.GameState = GameState.GameState.NORMAL_PLAY
var next_video_path: String = ""
var scene_after_video: String = ""

func set_game_state(new_state: GameState.GameState) -> void:
	game_state = new_state

func announce_dutch() -> void:
	dutched = true

func reset_dutch() -> void:
	dutched = false

func animate_card_to_position(card: Card, new_position: Vector2, speed: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	
func reset_drawn_this_turn() -> void:
	drawn_this_turn = false
	
func set_drawn_this_turn() -> void:
	drawn_this_turn = true
	
func reset_played_card() -> void:
	has_played_card = false
	
func set_played_card() -> void:
	has_played_card = true 

func toggle_turn_type() -> void:
	turn = TurnType.TurnType.OPPONENT if turn == TurnType.TurnType.PLAYER else TurnType.TurnType.PLAYER

func play_cutscene(video_path: String, next_scene: String):
	next_video_path = video_path
	scene_after_video = next_scene
	get_tree().change_scene_to_file("res://scenes/levels/cutscene_player.tscn")
