extends ModContainer

# Name, Author, Difficulty : Description, Resource Pack, Total Levels

func update_visuals() -> void:
	%Name.text = json["name"]
	%Author.text = json["author"]
	
	%Thumbnail.texture = get_image()
	
	var i := 0
	for star in %DifficultyStars.get_children():
		star.region_rect.position.x = 32 if i > json["difficulty"] else [0, 8, 8, 16, 24][json["difficulty"]]
		i += 1

func get_image() -> Texture:
	if (LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS[idx] != null):
		return LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS[idx]
	else:
		return ModContainer.NO_ICON_IMAGE
