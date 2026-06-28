class_name ModsMenu extends Node

const DEFAULT_PATH := "/Mods_Menu/"

var path_arr := []
var current_path := "/"

func _enter_tree() -> void:
	Global.get_node(^"GameHUD").hide()

func _ready() -> void:
	%SectionSelector.open()
	reset_path()

func _exit_tree() -> void:
	Global.get_node(^"GameHUD").show()

func reset_path() -> void:
	path_arr.clear()
	current_path = DEFAULT_PATH
	
	update_path()

func update_path(go_to_basename := false, path_joiner := "") -> void:
	path_arr.erase("wiki_opened...") # Because of the animation
	if (go_to_basename):
		path_arr.pop_back()
	if (path_joiner != ""):
		path_arr.append(path_joiner)
	
	current_path = DEFAULT_PATH
	for path: String in path_arr:
		current_path = current_path.path_join(tr(path))
	
	%Title.text = current_path
	
func wiki_path_anim() -> void:
	update_path(false, "wiki_opened...")
	await get_tree().create_timer(3, true).timeout
	if (path_arr.has("wiki_opened...")):
		update_path(true)

func go_to_title_screen() -> void:
	Global.transition_to_scene("res://Scenes/Levels/TitleScreen.tscn")

func go_to_custom_levels_menu() -> void:
	CustomLevelMenu.entered_from_mods_menu = true
	Global.transition_to_scene("res://Scenes/Levels/CustomLevelMenu.tscn")
