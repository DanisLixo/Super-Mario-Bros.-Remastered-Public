class_name CustomObjectsGetter
extends Node

static var OBJECTS_ZIP_FOLDER = ""
static var OBJECTS_VIRTUAL_FOLDER = "res://custom_objects-unpacked"
const OBJECT_INFO := "ObjectInfo.json"

static var JSON_EXAMPLE := {
	"script": "",
	"scene": "",
	"offset": [0, 0],
	
	"properties": {
		"name" : "",
		"description" : "",
		"type" : "tile",
		"icon": {
			"texture": "",
			"region_override": [0, 0, 0, 0]
		},
		"secondary_icon": {
			"texture": "",
			"region_override": [0, 0, 0, 0]
		}
	},
	"tile": {
		"source_id": 0,
		"terrain_id": 0,
		"tile_coords": 0,
		"flip_h": 0,
		"flip_v": 0
	},
	"metadata": {}
}

const base64_charset := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
const tileSelectorScene := preload("res://Scenes/Prefabs/Editor/EditorTileSelector.tscn")
const tileScrollerScene := preload("res://Scenes/Prefabs/Editor/EditorSelectorScroller.tscn")

static var customs := []
static var selectors := []

static func set_zips_folder() -> void:
	OBJECTS_ZIP_FOLDER = Global.config_path.path_join("/custom_objects")

static func merge_customs_to_map() -> void:
	for selector: EditorTileSelector in selectors:
		EntityIDMapper.map[selector.entity_id] = [selector.scene_path, str(selector.tile_offset.x) + "," + str(selector.tile_offset.y)]

static func find_objects() -> void:
	set_zips_folder()
	customs.clear()
	
	if (!DirAccess.dir_exists_absolute(OBJECTS_ZIP_FOLDER)):
		DirAccess.make_dir_recursive_absolute(OBJECTS_ZIP_FOLDER)
	
	var object_paths := _ModLoaderPath.get_dir_paths_in_dir(OBJECTS_VIRTUAL_FOLDER)
	if !OS.has_feature("editor"):
		object_paths = _ModLoaderPath.get_zip_paths_in(OBJECTS_ZIP_FOLDER)
	else:
		object_paths.append_array(_ModLoaderPath.get_zip_paths_in(OBJECTS_ZIP_FOLDER))
	
	var loaded_names := []
	for object_path in object_paths:
		var mod_name = object_path.get_basename().split("/")[-1]
		if loaded_names.has(mod_name):
			continue
		
		var is_zip = object_path.get_extension() == "zip"
		var object_info: Dictionary
		if is_zip:
			object_info = _ModLoaderFile.get_json_as_dict_from_zip(object_path, OBJECT_INFO)
			
			var is_mod_loaded_successfully := ProjectSettings.load_resource_pack(object_path)
			if not is_mod_loaded_successfully:
				Global.log_error("Failed to load custom object from path \"%s\". It can somehow be corrupted." % object_path)
				continue
		else:
			var file = FileAccess.open(object_path.path_join(OBJECT_INFO), FileAccess.READ).get_as_text()
			object_info = JSON.parse_string(file)
		
		if object_info == null || object_info.is_empty():
			continue
		
		var json := JSON_EXAMPLE.duplicate_deep()
		Global.merge_dict(json, object_info)
		if json["scene"] == null:
			continue
		
		loaded_names.push_back(mod_name)
		customs.push_back([OBJECTS_VIRTUAL_FOLDER.path_join(mod_name), json])
		print("Object got installed(?), check: %s" % str(DirAccess.get_files_at(OBJECTS_VIRTUAL_FOLDER.path_join(mod_name))))

func instantiate_selectors() -> void:
	selectors.clear()
	
	for object in customs:
		create_tile_selector(object[0], object[1])

func create_tile_selector(objPath: String = "", json: Dictionary = JSON_EXAMPLE) -> void:
	var tileSelect: EditorTileSelector = tileSelectorScene.instantiate()
	
	tileSelect.is_mod = true
	
	tileSelect.mod_path = objPath
	if (json["scene"].contains("res://")):
		tileSelect.scene_path = json["scene"]
	else:
		tileSelect.scene_path = objPath.path_join(json["scene"])
	tileSelect.entity_scene = load(tileSelect.scene_path)
	tileSelect.tile_offset = Vector2i(json["offset"][0], json["offset"][1]) 
	
	tileSelect.tile_name = json.properties["name"]
	tileSelect.tile_desc = json.properties["description"]
	var type := 0
	match (json.properties["type"]):
		"entity": type = 1
		"terrain": type = 2
	tileSelect.type = type
	
	if (json.properties.icon["texture"].contains("res://")):
		tileSelect.icon_texture = load(json.properties.icon["texture"])
	else:
		tileSelect.icon_texture = load(objPath.path_join(json.properties.icon["texture"]))
	var rect = json.properties.icon["region_override"]
	tileSelect.icon_region_override = Rect2(rect[0], rect[1], rect[2], rect[3])
	
	if (json.properties.secondary_icon["texture"].contains("res://")):
		tileSelect.secondary_icon_texture = load(json.properties.secondary_icon["texture"])
	else:
		tileSelect.secondary_icon_texture = load(objPath.path_join(json.properties.secondary_icon["texture"]))
	var rect2 = json.properties.secondary_icon["region_override"]
	tileSelect.secondary_icon_region_override = Rect2(rect2[0], rect2[1], rect2[2], rect2[3])
	
	for i in json["tile"].keys():
		tileSelect.set(i, json.tile[i])
	
	for i in json["metadata"].keys():
		tileSelect.set_meta(i, json.metadata[i])
	
	if (LevelEditor.level_file.has("Mods")):
		for id in LevelEditor.level_file["Mods"]:
			if LevelEditor.level_file["Mods"][id][0] == tileSelect.scene_path:
				tileSelect.entity_id = id
	
	tileSelect.add_to_group("Selectors")
	selectors.append(tileSelect)
	%Customs.add_child(tileSelect)

static func set_local_custom_id(selector: EditorTileSelector) -> void:
	var objInfoPath = selector.mod_path.path_join("ObjectInfo.json")
	var file: Dictionary = JSON.parse_string(FileAccess.open(objInfoPath, FileAccess.READ).get_as_text())
	var mod_scene = selector.mod_path.path_join(file["scene"])
	
	if !LevelEditor.level_file.has("Mods"):
		LevelEditor.level_file["Mods"] = {}
	
	for i in LevelEditor.level_file["Mods"]:
		if LevelEditor.level_file["Mods"][i][0] == mod_scene:
			return
	
	var new_id = "AA"
	while EntityIDMapper.map.has(new_id) or LevelEditor.level_file["Mods"].has(new_id):
		new_id = encode_to_base64_2char(randi_range(0, 4096))
	selector.entity_id = new_id
	
	LevelEditor.level_file["Mods"][new_id] = [selector.scene_path, str(selector.tile_offset.x) + "," + str(selector.tile_offset.y)]
	
	merge_customs_to_map()

static func encode_to_base64_2char(value: int) -> String:
	if value < 0 or value >= 4096:
		push_error("Value out of range for 2-char base64 encoding.")
		return ""

	var char1 = base64_charset[(value >> 6) & 0b111111]  # Top 6 bits
	var char2 = base64_charset[value & 0b111111]         # Bottom 6 bits

	return char1 + char2
