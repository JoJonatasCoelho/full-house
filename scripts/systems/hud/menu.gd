extends Control

@onready var menu_container: VBoxContainer = $MenuContainer
@onready var settings_container: VBoxContainer = $SettingsContainer

@onready var check_fullscreen: CheckBox = $SettingsContainer/FullscreenCheckBox

const INTRO_VIDEO_PATH = "res://assets/cutscenes/1_cutscene.ogv"
const FIRST_LEVEL_PATH = "res://scenes/levels/battles/chor.tscn"

func _ready() -> void:
	var current_mode = DisplayServer.window_get_mode()
	check_fullscreen.button_pressed = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	Global.play_cutscene(INTRO_VIDEO_PATH, FIRST_LEVEL_PATH)
	
func _on_settings_button_pressed() -> void:
	menu_container.visible = false
	settings_container.visible = true


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/credits.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	settings_container.visible = false
	menu_container.visible = true


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_load_button_pressed() -> void:
	SaveManager._load()
	if SaveManager.save_data.current_scene != "":
		get_tree().change_scene_to_file(SaveManager.save_data.current_scene)
