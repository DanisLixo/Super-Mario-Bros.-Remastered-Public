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
		
		var json := JSONParser.parse_to_dict(ModsLoader.level_packs_path.path_join(i).path_join("pack_info.json"))
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

	if pack_json.is_empty():
		continue
	if (!pack_json.has("number_of_worlds") || (pack_json.has("number_of_worlds") && pack_json["number_of_worlds"] == 0)):
		Global.log_error("Couldn't load level pack: \"%s\". Missing number of worlds." % i)
		continue
	else:
		Level.WORLD_COUNTS[i] = pack_json.number_of_worlds
	if (!pack_json.has("levels_per_world") || (pack_json.has("levels_per_world") && pack_json["levels_per_world"].is_empty())):
		Global.log_error("Couldn't load level pack: \"%s\". Missing levels per world." % i)
		continue
	if (!pack_json.has("levels") || (pack_json.has("levels") && pack_json["levels"].is_empty())):
		Global.log_error("Couldn't load level pack: \"%s\". There are no levels listed." % i)
		continue

	Global.custom_campaign_jsons[i] = json
	Global.custom_campaigns.append(i)
	campaign.append(i)
	campaign_icons.append(ImageTexture.create_from_image(Image.load_from_file(Global.config_path.path_join("level_packs/").path_join(i).path_join("icon.png"))))
	var title: Label = %Custom.duplicate()
	var pack_name = "???" if !pack_json.has("name") else pack_json["name"]
	var pack_author = "UNKNOWN" if !pack_json.has("author") else pack_json["author"]
	title.text = pack_name + "\nBy " + pack_author
	if (pack_json.has("text_colour")):
		title.add_theme_color_override("font_shadow_color", Color(pack_json.text_colour))
	if (!(pack_json.has("name") || pack_json.has("author") || pack_json.has("text_colour"))):
		# DawnLR: Those are essentials to have, the rest are just for information, so the level pack can proceed from here with a warning.
		Global.log_warning("There is missing information for level pack: \"%s\" " % i)
		
