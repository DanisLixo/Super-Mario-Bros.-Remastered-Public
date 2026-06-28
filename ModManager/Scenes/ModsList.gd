class_name ModsList
extends VBoxContainer

enum ModListing {
	CHARACTERS, RESOURCE_PACKS, LEVEL_PACKS, GML, BLUEPRINTS, SCREENSHOTS
}
const LIST_CONTAINERS = [
	preload("res://ModManager/Scenes/Manager/Containers/List/CharacterContainer.tscn"),
	null, #preload(""), # Level Packs
	preload("res://ModManager/Scenes/Manager/Containers/List/LevelPackContainer.tscn"),
	null, #preload("res://ModManager/Scenes/Manager/Containers/GMLModContainer.tscn"),
	null, #preload(""), # Blueprints
	null, #preload(""), # Screenshots
]
const GRID_CONTAINERS = [
	null, #preload("res://ModManager/Scenes/Manager/Containers/Grid/CharacterContainer.tscn"),
	null, #preload(""), # Resource Packs
	null, #preload(""), # Level Packs
	null, #preload("res://ModManager/Scenes/Manager/Containers/GMLModContainer.tscn"),
	null, #preload(""), # Blueprints
	null, #preload(""), # Screenshots
]
var FOLDER_PATHS = [
	ModsLoader.characters_path, 
	ModsLoader.resource_packs_path, 
	ModsLoader.level_packs_path, 
	ModsLoader.gml_path, 
	ModsLoader.blueprints_path, 
	ModsLoader.screenshots_path
]

signal opened
signal closed

signal mod_selected(container: ModContainer)

var containers_arr := LIST_CONTAINERS

# It's a global list and as you can't get two categories at the same time, why not?
var containers := []
var current_content_idx := ModListing.CHARACTERS

var selected_idx := -1
var search_check := ""

@onready var current_list := %ListContainers
@export_enum("List", "Grid") var listing_mode := 0: set = set_listing_mode

func _ready() -> void:
	set_listing_mode(listing_mode)
	set_process(false)

func _process(_delta: float) -> void:
	if (Global.multibind_action_just_pressed("ui_back") || Input.is_action_just_pressed("mb_right")) and CustomLineEdit.editing == false:
		close()

func set_listing_mode(value := 0) -> void:
	listing_mode = value
	current_list = %ListContainers if listing_mode == 0 else %GridContainers
	containers_arr = LIST_CONTAINERS if listing_mode == 0 else GRID_CONTAINERS

func refresh() -> void:
	current_list.get_node("Label").show()
	for i in current_list.get_children():
		if i is ModContainer:
			i.queue_free()
	containers.clear()
	
	create_list(%ModsLoader.get_mods(current_content_idx), current_content_idx)

func create_list(content_array := [], type := ModListing.CHARACTERS) -> void:
	var idx := 0
	for i in content_array:
		var container := create_container(idx, i, type)
		if (container == null):
			continue
		if (idx == 0):
			current_list.get_node("Label").hide()
		
		containers.append(container)
		container.selected.connect(container_selected)
		current_list.add_child(container)
		
		idx += 1

func create_container(idx := -1, content := "", type := ModListing.CHARACTERS) -> ModContainer:
	var path = FOLDER_PATHS[current_content_idx]
	var file_path = path.path_join(content)
	
	var container: ModContainer = containers_arr[type].instantiate()
	##In Chain
	match(type):
		ModListing.CHARACTERS:
			container.idx = idx + CharactersHandler.DEFAULT_CHARACTERS.size() # I lowkey don't care if it's already a fixed size.
			container.file_path = file_path
			container.mod_id = content
			
			container.json = JSONParser.parse_json_to_dict(file_path.path_join("CharacterInfo.json"))
		ModListing.LEVEL_PACKS:
			container.idx = idx
			container.file_path = file_path
			container.mod_id = content
			
			container.json = JSONParser.parse_json_to_dict(file_path.path_join("pack_info.json"))
	return container

func open(mode := ModListing.CHARACTERS, refresh_list := true) -> void:
	%ManagerSelector.close(false)
	
	current_content_idx = mode
	
	show()
	opened.emit()
	
	if refresh_list:
		refresh()
	else:
		get_parent().mods_menu.update_path(false, FOLDER_PATHS[current_content_idx])
	if selected_idx >= 0:
		current_list.get_child(selected_idx).grab_focus()
	
	get_parent().set_process(false)
	await get_tree().process_frame
	set_process(true)

func close() -> void:
	hide()
	closed.emit()
	set_process(false)
	owner.update_path(true)

func container_selected(container: CustomLevelContainer) -> void:
	if container.is_autosave: return
	
	mod_selected.emit(container)
	selected_idx = container.get_index()

func open_folder() -> void:
	var mods_path = FOLDER_PATHS[current_content_idx]
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(mods_path))
