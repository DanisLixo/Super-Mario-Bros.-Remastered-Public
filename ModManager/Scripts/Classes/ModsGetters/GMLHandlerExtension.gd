class_name GMLHandler extends Node

static var GML_MODS := []
static var GML_MOD_ICONS := []
static var GML_MOD_JSONS := {}

static var disabled_mods := []
# This includes Character Select's get_custom_characters method.
static func get_gml_mods(deep := false) -> void:
	clear_mods_list()
	
	var mod_dir = ModsLoader.gml_path
	for i in DirAccess.get_files_at(mod_dir):
		if i.contains(".zip") == false:
			continue
			
		var mod_path = mod_dir.path_join(i)
		
		var json := get_mod_manifest(i, mod_path)
		register_mod(i, json, mod_path)

	if (deep):
		mod_dir = mod_dir.path_join(".disabled")
		for i in DirAccess.get_files_at(mod_dir):
			if i.contains(".zip") == false:
				continue
				
			var mod_path = mod_dir.path_join(i)
			
			var json := get_mod_manifest(i, mod_path)
			register_mod(i, json, mod_path)

static func register_mod(mod_id := "", mod_json := {}, mod_path := "") -> void:
	GML_MODS.append(mod_id)
	GML_MOD_JSONS[mod_id] = mod_json
	GML_MOD_ICONS.append(get_mod_icon(mod_id, mod_path))

static func clear_mods_list() -> void:
	GML_MODS.clear()
	GML_MOD_JSONS.clear()
	GML_MOD_ICONS.clear()

static func get_mod_icon(mod_id := "", mod_path := "") -> Texture2D:
	var local_path := _ModLoaderPath.get_local_folder_dir(mod_id).path_join("icon.png")
	if (FileAccess.file_exists(local_path)):
		return load(local_path)
	var image := Image.new()
	var reader := ZIPReader.new()
	reader.open(mod_path)
	
	var image_path := ""
	for i in reader.get_files():
		if i.contains("icon.png"):
			image_path = i
			break
	if (!reader.file_exists(image_path)):
		return null
	
	var bytes = reader.read_file(image_path)
	if !bytes.is_empty():
		image.load_png_from_buffer(bytes)
	reader.close()
	
	if (image != null):
		return ImageTexture.create_from_image(image)
	else:
		return null

static func get_mod_manifest(mod_id := "", mod_path := "") -> Dictionary:
	var local_path := _ModLoaderPath.get_path_to_mod_manifest(mod_id)
	if (FileAccess.file_exists(local_path)):
		return JSONParser.parse_json_to_dict(local_path)
	
	var reader := ZIPReader.new()
	reader.open(mod_path)
	
	var manifest_path := ""
	for i in reader.get_files():
		if i.contains("manifest.json"):
			manifest_path = i
			break
	
	var json_str = reader.read_file(manifest_path).get_string_from_utf8()
	reader.close()
	
	return JSONParser.parse_string_to_dict(json_str)

static func move_file(path_from := "", move_to := "") -> void:
	ModsTransfer.move_file(path_from, move_to)
