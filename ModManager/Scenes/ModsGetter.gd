class_name ModsLoader extends Node

const DEFAULT_MODS_DICT := {
	"all": [], 
	"disabled": []
}

static var config_path := get_config_path()

static var characters_path = config_path.path_join("custom_characters")
static var resource_packs_path = config_path.path_join("resource_packs")
static var level_packs_path = config_path.path_join("level_packs")
static var gml_path = config_path.path_join("mods")
static var blueprints_path = config_path.path_join("blueprints")
static var screenshots_path = config_path.path_join("screenshots")

static func get_config_path() -> String:
	var exe_path := OS.get_executable_path()
	var exe_dir  := exe_path.get_base_dir()
	var portable_flag := exe_dir.path_join("portable.txt")
	
	# Test that exe dir is writeable, if not fallback to user://
	if FileAccess.file_exists(portable_flag):
		var test_file = exe_dir.path_join("test.txt")
		var f = FileAccess.open(test_file, FileAccess.WRITE)
		if f:
			f.close()
			var dir = DirAccess.open(exe_dir)
			if dir:
				dir.remove(test_file.get_file())
			var local_dir = exe_dir.path_join("config")
			if not DirAccess.dir_exists_absolute(local_dir):
				DirAccess.make_dir_recursive_absolute(local_dir)
			return local_dir
		else:
			push_warning("Portable flag found but exe directory is not writeable. Falling back to user://")
	return "user://"

func get_mods(mode := ModsList.ModListing.CHARACTERS) -> Dictionary:
	##InChain
	match(mode):
		ModsList.ModListing.CHARACTERS:
			return get_custom_characters()
		ModsList.ModListing.RESOURCE_PACKS:
			return get_resource_packs()
		ModsList.ModListing.LEVEL_PACKS:
			return get_level_packs()
		ModsList.ModListing.GML:
			return get_gml_mods()
		ModsList.ModListing.BLUEPRINTS:
			return DEFAULT_MODS_DICT.duplicate()
		ModsList.ModListing.SCREENSHOTS:
			return DEFAULT_MODS_DICT.duplicate()
		_:
			return DEFAULT_MODS_DICT.duplicate()

func get_custom_characters() -> Dictionary:
	CharactersHandler.get_custom_characters(true)
	
	var dict := DEFAULT_MODS_DICT.duplicate()
	
	dict.all = CharactersHandler.CHARACTERS.duplicate(true)
	for i in CharactersHandler.DEFAULT_CHARACTERS:
		dict.all.erase(i)
	dict.disabled = CharactersHandler.disabled_mods
	
	return dict

func get_resource_packs() -> Dictionary:
	var resource_packs = []
	return resource_packs

func get_level_packs() -> Dictionary:
	LevelPacksHandler.get_level_packs(true)
	
	var dict := DEFAULT_MODS_DICT.duplicate()
	dict.all = LevelPacksHandler.CUSTOM_CAMPAIGNS.duplicate(true)
	dict.disabled = LevelPacksHandler.disabled_mods
	
	return dict

func get_gml_mods() -> Dictionary:
	GMLHandler.get_gml_mods(true)
	
	var dict := DEFAULT_MODS_DICT.duplicate()
	dict.all = GMLHandler.GML_MODS.duplicate(true)
	dict.disabled = GMLHandler.disabled_mods
	
	return dict
