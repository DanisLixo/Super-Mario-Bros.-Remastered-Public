class_name CharactersHandler extends Node

const DEFAULT_CHARACTERS := ["Mario", "Luigi", "Toad", "Toadette"]
const DEFAULT_CHARACTER_NAMES := ["CHAR_MARIO", "CHAR_LUIGI", "CHAR_TOAD", "CHAR_TOADETTE"]
const DEFAULT_CHARACTER_AUTHORS := ["NINTENDO", "NINTENDO", "NINTENDO", "NINTENDO"]
const DEFAULT_CHARACTER_COLOURS := [
	preload("res://Assets/Sprites/Players/Mario/CharacterColour.json"), 
	preload("res://Assets/Sprites/Players/Luigi/CharacterColour.json"), 
	preload("res://Assets/Sprites/Players/Toad/CharacterColour.json"), 
	preload("res://Assets/Sprites/Players/Toadette/CharacterColour.json")
]
const DEFAULT_CHARACTER_PALETTES := [
	preload("res://Assets/Sprites/Players/Mario/ColourPalette.json"),
	preload("res://Assets/Sprites/Players/Luigi/ColourPalette.json"),
	preload("res://Assets/Sprites/Players/Toad/ColourPalette.json"),
	preload("res://Assets/Sprites/Players/Toadette/ColourPalette.json")
]
const DEFAULT_CHARACTER_ICONS := [
	preload("res://Assets/Sprites/Players/Mario/LifeIcon.json"),
	preload("res://Assets/Sprites/Players/Luigi/LifeIcon.json"),
	preload("res://Assets/Sprites/Players/Toad/LifeIcon.json"),
	preload("res://Assets/Sprites/Players/Toadette/LifeIcon.json")
]

# I decided to put all characters arrays inside the handler so everything is within the handler...
static var CHARACTERS := DEFAULT_CHARACTERS.duplicate()
static var CHARACTER_NAMES := DEFAULT_CHARACTER_NAMES.duplicate()
static var CHARACTER_AUTHORS := DEFAULT_CHARACTER_AUTHORS.duplicate()
static var CHARACTER_COLOURS := DEFAULT_CHARACTER_COLOURS.duplicate()
static var CHARACTER_PALETTES := DEFAULT_CHARACTER_PALETTES.duplicate()
static var CHARACTER_ICONS := DEFAULT_CHARACTER_ICONS.duplicate()

static var disabled_mods := []

# This includes Character Select's get_custom_characters method.
static func get_custom_characters(deep := false) -> void:
	clear_characters_list()
	
	apply_resource_pack_changes()
	
	var base_path = Global.config_path
	var char_dir = base_path.path_join("custom_characters") 
	for i in DirAccess.get_directories_at(char_dir):
		var char_path = char_dir.path_join(i)
		var char_info_path = char_path.path_join("CharacterInfo.json")
		
		if (!deep):
			if (disabled_mods.has(i)):
				continue
		if !FileAccess.file_exists(char_info_path):
			continue
		
		var json := JSONParser.parse_json_to_dict(char_path.path_join("CharacterInfo.json"))
		
		if json.has("physics"):
			if json.physics.has("PHYSICS_PARAMETERS") == false:
				json = CustomCharacterUpdater.update_json(json)
				Global.log_comment("Updated CharacterInfo for: " + i)
				FileAccess.open(char_path.path_join("CharacterInfo.json"), FileAccess.WRITE).store_string((JSON.stringify(json, "\t", false)))
		
		import_character(i, char_path, json)

static func import_character(char_id := "", char_path := "", char_json := {}) -> void:
	CHARACTERS.append(char_id)
	if (char_json.has("name")):
		CHARACTER_NAMES.append(char_json.name)
	else:
		CHARACTER_NAMES.append("NAME NOT SET")
	if (char_json.has("author")):
		CHARACTER_AUTHORS.append(char_json.author)
	else:
		CHARACTER_AUTHORS.append("UNKNOWN")
	
	if FileAccess.file_exists(char_path.path_join("CharacterColour.json")):
		CHARACTER_COLOURS.append(load(char_path.path_join("CharacterColour.json")))
	else:
		CHARACTER_COLOURS.append(null)
	
	if FileAccess.file_exists(char_path.path_join("LifeIcon.json")):
		CHARACTER_ICONS.append(load(char_path.path_join("LifeIcon.json")))
	else:
		CHARACTER_ICONS.append(null)
		
	if FileAccess.file_exists(char_path.path_join("ColourPalette.json")):
		CHARACTER_PALETTES.append(load(char_path.path_join("ColourPalette.json")))
	else:
		CHARACTER_PALETTES.append(null)
	
	AudioManager.character_sfx_map[char_id] = JSONParser.parse_json_to_dict(char_path.path_join("SFX.json"))

static func clear_characters_list() -> void:
	CHARACTERS = DEFAULT_CHARACTERS.duplicate()
	CHARACTER_NAMES = DEFAULT_CHARACTER_NAMES.duplicate()
	CHARACTER_AUTHORS = DEFAULT_CHARACTER_AUTHORS.duplicate()
	CHARACTER_COLOURS = DEFAULT_CHARACTER_COLOURS.duplicate()
	CHARACTER_PALETTES = DEFAULT_CHARACTER_PALETTES.duplicate()
	CHARACTER_ICONS = DEFAULT_CHARACTER_ICONS.duplicate()
	AudioManager.character_sfx_map.clear()

static func apply_resource_pack_changes():
	for i in DEFAULT_CHARACTERS.size():
		var character: String = CHARACTERS[i]
		
		var path = ResourceSetter.get_pure_resource_path("res://Assets/Sprites/Players/" + character + "/CharacterInfo.json")
		if FileAccess.file_exists(path):
			var json = JSONParser.parse_json_to_dict(path)
			if (json.has("name")):
				CHARACTER_NAMES[i] = json.name
		path = ResourceSetter.get_pure_resource_path("res://Assets/Sprites/Players/" + character + "/CharacterColour.json")
		if FileAccess.file_exists(path):
			CHARACTER_COLOURS[i] = load(path)
