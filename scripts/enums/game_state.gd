extends Node

class_name GameState

enum GameState {
	WAITING_START_PEEK, # Peek 2 cards
	NORMAL_PLAY,        
	POWER_QUEEN,        # Select a card to peek
	POWER_JACK_STEP_1,  # Select first card to the jack
	POWER_JACK_STEP_2   # Select second card to the jack
}
