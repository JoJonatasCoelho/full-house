extends Node

var victory = {
	1: "Poderia ter dado dutch de primeira",
	2: "Cozinhou",
	3: "Isso teria sido lendário na era dos humanos"
}

var lose = {
	1: "Descartou um rei preto",
	2: "Foi misclick",
	3: "Não sabe a hora de dar dutch"
}

func get_message(i: int, is_winner: bool = true) -> String:
	if is_winner:
		return victory[i]
	return lose[i]
	
