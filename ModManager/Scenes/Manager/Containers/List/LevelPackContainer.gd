class_name LevelPackContainer extends ModContainer

var difficulty := 0

func update_visuals() -> void:
	super()
	
	%Thumbnail.texture = get_image()
	
	if (json.has("name")):
		%Name.text = json["name"]
	if (json.has("author")):
		%Author.text = json["author"]
	%Levels.text = tr("MODS_PACK_TOTAL_LEVELS") + ": " + str(json["levels"].size())
	if (json.has("difficulty")):
		difficulty = json["difficulty"]
		difficulty = clampi(difficulty, 0, 4)
	
	var res_pack_name := tr("MODS_NO_RESOURCE_PACK")
	if (json.has("resource_pack") && json["resource_pack"] != "" && json["resource_pack"] != null):
		res_pack_name = json["resource_pack"]
	
	%ResourcePack.text = "Res. Pack: " + res_pack_name
	
	var _idx := 0
	for i in %DifficultyStars.get_children():
		i.region_rect.position.x = 32 if _idx > difficulty else [0, 8, 8, 16, 24][difficulty]
		_idx += 1

func get_image() -> Texture2D:
	if (LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS[idx] != null):
		return LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS[idx]
	else:
		return ModContainer.NO_ICON_IMAGE
