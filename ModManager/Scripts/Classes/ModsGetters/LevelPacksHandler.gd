class_name LevelPacksHandler extends Node

static var CUSTOM_CAMPAIGNS := []
static var CUSTOM_CAMPAIGN_ICONS := []
static var CUSTOM_CAMPAIGN_JSONS := {}

static var disabled_mods := []

static func get_level_packs(deep := false) -> void:
	clear_level_packs_list()
	
	for i in DirAccess.get_directories_at(ModsLoader.level_packs_path):
		if (!deep):
			if (disabled_mods.has(i)):
				continue
		
		var json := JSONParser.parse_json_to_dict(ModsLoader.level_packs_path.path_join(i).path_join("pack_info.json"))
		import_level_pack(i, json)

static func clear_level_packs_list() -> void:
	CUSTOM_CAMPAIGNS.clear()
	CUSTOM_CAMPAIGN_JSONS.clear()
	CUSTOM_CAMPAIGN_ICONS.clear()

static func import_level_pack(pack_folder := "", pack_json := {}) -> void:
	CUSTOM_CAMPAIGNS.append(pack_folder)
	CUSTOM_CAMPAIGN_JSONS[pack_folder] = pack_json
	
	var icon_path = ModsLoader.level_packs_path.path_join(pack_folder).path_join("icon.png")
	var icon_image = Image.load_from_file(icon_path)
	if (icon_image != null):
		CUSTOM_CAMPAIGN_ICONS.append(ImageTexture.create_from_image(icon_image))
