class_name ModsList
extends VBoxContainer

enum ModListing {
	CHARACTERS, RESOURCE_PACKS, LEVEL_PACKS, GML, BLUEPRINTS, SCREENSHOTS
}

##InChain
const LIST_CONTAINERS = [
	preload("res://ModManager/Scenes/Manager/Containers/List/CharacterContainer.tscn"),
	null, #preload(""), # Resource Packs
	preload("res://ModManager/Scenes/Manager/Containers/List/LevelPackContainer.tscn"),
	preload("res://ModManager/Scenes/Manager/Containers/List/GMLContainer.tscn"),
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

@onready var current_list = %Containers
@export_enum("List", "Grid") var listing_mode := 0: set = set_listing_mode

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if (Global.multibind_action_just_pressed("ui_back") || Input.is_action_just_pressed("mb_right")) and CustomLineEdit.editing == false:
		close()

func set_listing_mode(value := 0) -> void:
	listing_mode = value
	current_list = %Containers if listing_mode == 0 else [%EnabledGrid, %DisabledGrid]
	containers_arr = LIST_CONTAINERS if listing_mode == 0 else GRID_CONTAINERS

func refresh() -> void:
	%NoModsLabel.show()
	%Enabled.hide()
	%Disabled.hide()
	
	if (current_list is Array):
		for grid in current_list:
			for cont in grid.get_children():
				if cont is ModContainer:
					cont.queue_free()
			grid.hide()
	else:
		for cont in current_list.get_children():
			if cont is ModContainer:
				cont.queue_free()
	containers.clear()
	
	create_list(%ModsLoader.get_mods(current_content_idx), current_content_idx)

func create_list(content_dict := ModsLoader.DEFAULT_MODS_DICT.duplicate(), type := ModListing.CHARACTERS) -> void:
	var idx := 0
	for mod_id in content_dict.all:
		var disabled_mod = content_dict.disabled.has(mod_id)
		
		var container := create_container(idx, mod_id, type, disabled_mod)
		if (container == null):
			continue
		%NoModsLabel.hide()
		
		containers.append(container)
		container.selected.connect(container_selected)
		
		var current_category: Label = [%Enabled, %Disabled][int(content_dict.has(mod_id))]
		if (listing_mode == 0):
			
			current_category.show()
			current_list.move_child(container, current_category.get_index() + 1)
			current_list.add_child(container)
		elif (listing_mode == 1):
			var current_grid: Label = current_list[int(content_dict.has(mod_id))]
			
			current_category.show()
			current_grid.show()
			current_grid.add_child(container)
			current_grid.add_child(container)
		
		idx += 1

func create_container(idx := -1, mod_id := "", type := ModListing.CHARACTERS, disabled := false) -> ModContainer:
	var path = FOLDER_PATHS[current_content_idx]
	var file_path = path.path_join(mod_id)
	
	var container: ModContainer = containers_arr[type].instantiate()
	
	container.enabled = !disabled
	container.idx = idx
	container.file_path = file_path
	container.mod_id = mod_id
	##InChain
	match(type):
		ModListing.CHARACTERS:
			# I lowkey don't care if it's already a fixed size.
			container.idx += CharactersHandler.DEFAULT_CHARACTERS.size()
			container.json = JSONParser.parse_json_to_dict(file_path.path_join("CharacterInfo.json"))
		ModListing.LEVEL_PACKS:
			container.json = LevelPacksHandler.CUSTOM_CAMPAIGN_JSONS[mod_id]
		ModListing.GML:
			container.json = GMLHandler.GML_MOD_JSONS[mod_id]
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
