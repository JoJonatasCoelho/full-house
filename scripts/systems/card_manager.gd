extends Node2D

class_name CardManager

@onready var card_being_dragged : Card
@onready var is_hovering_a_card: bool = false
@onready var screen_size = get_viewport_rect().size

@onready var CARD_COLLISION_MASK: int = 1
@onready var SLOT_COLLISION_MASK: int = 2

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = mouse_pos
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
											  clamp(mouse_pos.y, 0, screen_size.y))
		

func connect_card_signals(card: Card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func highlight_card(card: Card, hovered: bool):
	if hovered:
		card.scale = Vector2(1.2, 1.2)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
	
	
func on_hovered_over_card(card: Card):
	if !is_hovering_a_card:
		is_hovering_a_card = true
		highlight_card(card, true)
	
func on_hovered_off_card(card: Card):
	highlight_card(card, false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_a_card = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index  == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag() 

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
	
func start_drag(card: Card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found:
		card_slot_found.card_in_slot = false
	

func finish_drag():
	card_being_dragged.scale = Vector2(1.2, 1.2)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.position = card_slot_found.position
		card_slot_found.card_in_slot = true 
	card_being_dragged = null
