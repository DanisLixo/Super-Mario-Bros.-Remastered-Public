class_name ResourcePackContainerNew extends ModContainer

var pack_icon: Texture

var load_order := 0

var config_path := ""
var config := {}

var old_idx := -1

func _ready() -> void:
	super()
	
	old_idx = get_index()

func update_visuals() -> void:
	super()
	
	if FileAccess.file_exists(mod_id.path_join("config.json")):
		config_path = mod_id.path_join("config.json")
		config = JSONParser.parse_to_dict(config_path)
	
	%Icon.texture = get_pack_icon(mod_id)
	
	if (json.has("name")):
		%Name.text = json.name.to_upper()
	else:
		%Name.text = mod_id
	
	if (json.has("description")):
		%Description.text = json.description.to_upper()
	else:
		%Description.text = ""
	
	%LoadedOrder.text = str(load_order)

func get_pack_icon(path := "") -> Texture:
	var texture: Texture = null
	
	if FileAccess.file_exists(path.path_join("icon.png")):
		var image = Image.new()
		image.load(path.path_join("icon.png"))
		texture = ImageTexture.create_from_image(image)
	elif FileAccess.file_exists(path.path_join("icon.gif")):
		texture =  GifManager.animated_texture_from_file(path.path_join("icon.gif"))
	
	return texture

func handle_toggle() -> void:
	if Global.custom_pack == mod_id:
		AudioManager.play_global_sfx("bump")
		Global.log_comment("Required Resource pack for Campaign cannot be disabled!", 0.5)
		return
	
	AudioManager.current_level_theme = ""
	ResourceGetter.cache.clear()
	ResourceSetter.cache.clear()
	ResourceSetterNew.clear_cache()
	if (enabled and Settings.file.mods.resource_packs.has(mod_id) == false):
		AudioManager.play_global_sfx("coin")
		
		Settings.file.mods.resource_packs.push_front(mod_id)
		if (!config.is_empty()):
			ResourceSetterNew.pack_configs[mod_id] = config
	else:
		AudioManager.play_global_sfx("bump")
		
		ResourceSetterNew.pack_configs.erase(mod_id)
		Settings.file.mods.resource_packs.erase(mod_id)
	Global.update_theme()
	
	Global.load_default_translations()
	TranslationServer.reload_pseudolocalization()
