class_name LevelPacksHandler extends Object

static var CUSTOM_CAMPAIGNS := []
static var CUSTOM_CAMPAIGN_ICONS := []
static var CUSTOM_CAMPAIGN_JSONS := {}

static func import_level_packs() -> void:
	_clear_level_packs_list()
	
	for i in DirAccess.get_directories_at(ModsLoader.level_packs_path):
		var json := JSONParser.parse_to_dict(ModsLoader.level_packs_path.path_join(i).path_join("pack_info.json"))
		_import_level_pack(i, json)

static func get_level_packs(deep := false):
	var dict := CUSTOM_CAMPAIGNS.duplicate()
	if (!deep): 
		for i in Settings.file.mods.disabled_level_packs:
			dict.erase(i)
	return dict

static func enable_level_pack(lp_id := "") -> void:
	if (!CUSTOM_CAMPAIGNS.has(lp_id)):
		return
	
	Settings.file.mods.disabled_level_packs.erase(lp_id)
	Settings.save_settings()

static func disable_level_pack(lp_id := "") -> void:
	if (!CUSTOM_CAMPAIGNS.has(lp_id)):
		return
	
	Settings.file.mods.disabled_level_packs.append(lp_id)
	Settings.save_settings()

static func _clear_level_packs_list() -> void:
	CUSTOM_CAMPAIGNS.clear()
	CUSTOM_CAMPAIGN_JSONS.clear()
	CUSTOM_CAMPAIGN_ICONS.clear()

static func _import_level_pack(pack_folder := "", pack_json := {}) -> void:
	CUSTOM_CAMPAIGNS.append(pack_folder)
	CUSTOM_CAMPAIGN_JSONS[pack_folder] = pack_json
	
	var icon_path = ModsLoader.level_packs_path.path_join(pack_folder).path_join("icon.png")
	var icon_image = Image.load_from_file(icon_path)
	CUSTOM_CAMPAIGN_ICONS.append(ImageTexture.create_from_image(icon_image))
	if (!pack_json.has("number_of_worlds") || (pack_json.has("number_of_worlds") && pack_json["number_of_worlds"] == 0)):
		Global.log_error("Couldn't load level pack: \"%s\". Missing number of worlds." % pack_folder)
	else:
		Level.WORLD_COUNTS[pack_folder] = pack_json.number_of_worlds
	if (!pack_json.has("levels_per_world") || (pack_json.has("levels_per_world") && pack_json["levels_per_world"].is_empty())):
		Global.log_error("Couldn't load level pack: \"%s\". Missing levels per world." % pack_folder)
	if (!pack_json.has("levels") || (pack_json.has("levels") && pack_json["levels"].is_empty())):
		Global.log_error("Couldn't load level pack: \"%s\". There are no levels listed." % pack_folder)
