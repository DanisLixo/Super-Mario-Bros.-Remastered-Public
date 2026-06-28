class_name LevelPackContainer extends ModContainer

var difficulty := 0

const DIFFICULTY_TO_STAR_TRANSLATION := {
	"Easy": 0,
	"Medium": 2,
	"Hard": 3,
	"Extreme": 4
}

func update_visuals() -> void:
	super()
	%Thumbnail.texture = import_image()
	
	if (json.has("name")):
		%Name.text = json["name"]
	if (json.has("author")):
		%Author.text = json["author"]
	%Levels.text = tr("PACK_TOTAL_LEVELS") + ": " + str(json["levels"].size())
	if (json.has("difficulty")):
		difficulty = json["difficulty"]
	
	#var idx := 0
	#var difficulty_int = DIFFICULTY_TO_STAR_TRANSLATION[difficulty]
	#for i in %DifficultyStars.get_children():
		#i.region_rect.position.x = 32 if idx > difficulty_int else [0, 8, 8, 16, 24][difficulty_int]
		#idx += 1

func import_image() -> Texture:
	var texture := load("res://Assets/Sprites/UI/LevelPackIconEmpty.png")
	
	var image = LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS[idx]
	if (image != null):
		texture = image
	
	return texture
