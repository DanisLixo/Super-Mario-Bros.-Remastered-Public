extends Node

enum TemplateMode {CHARACTER, LEVEL_PACK, RESOURCE_PACK}

var files := []
var directories := []

signal file_downloaded(text: String)
var downloaded_file := []

signal template_created(mode)

const resource_pack_base_info_json := {
	"name": "New Pack",
	"description": "Template, give me a description!",
	"author": "Me, until you change it",
	"version": "1.0"
	}
	
const level_pack_base_info_json := {
	"name": "Test Pack",
	"text_colour": "1f1f1f",
	"author": "JoeMama",
	"description": "Hello :)",
	"difficulty": 0,
	"resource_pack": "smas pack demo version",
	"number_of_worlds": 8,
	"levels_per_world": [5, 4, 4, 4, 4, 4, 4, 4],

	"world_themes": [
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"],
		["Overworld", "Day"]
	],

	"levels": [
        "1.lvl"
	]
}
	
const disallowed_files := ["bgm","ctex","json", "fnt", "svg", "txt", "lvl"]
const extention_blacklist := ["txt", "svg"]

func create_template(mode := TemplateMode.RESOURCE_PACK) -> void:
	var resources_path := "res://Assets"
	var new_path = ModsLoader.resource_packs_path.path_join("new_pack")
	
	match(mode):
		TemplateMode.CHARACTER:
			resources_path = "res://Assets/Sprites/Players/Mario"
			new_path = ModsLoader.characters_path.path_join("new_character")
		TemplateMode.LEVEL_PACK:
			resources_path = "res://Resources/LevelPackTemplate"
			new_path = ModsLoader.level_packs_path.path_join("new_pack")
	
	get_directories(resources_path, files, directories)
	
	for i in directories:
		DirAccess.make_dir_recursive_absolute(i.replace(resources_path, new_path))
	for i in files:
		if i.get_extension() in extention_blacklist:
			continue
		var destination = i
		if destination.contains("res://"):
			destination = i.replace(resources_path, new_path)
		else:
			destination = i.replace(ModsLoader.resource_packs_path.path_join("BaseAssets/Sprites/Players/Mario"), new_path)
		var data = []
		if i.contains(".fnt"):
			print("Got fnt file")
			var fnt_file = FileAccess.open(i.replace(".fnt", ".txt"), FileAccess.READ)
			print(fnt_file)
			data = fnt_file.get_buffer(fnt_file.get_length())
			print(data)
		elif i.ends_with("/ScoreFont.png"):
			# For some reason, Godot's BMFont importer REALLY
			# doesn't like ScoreFont when the PNG is saved at runtime
			data = FileAccess.get_file_as_bytes(i + ".txt")
		elif disallowed_files.has(i.get_extension()) == false and i.contains("res://"):
			var resource = load(i)
			if resource is Texture:
				if OS.is_debug_build(): print("texture:" + i)
				var image: Image = resource.get_image()
				image.convert(Image.FORMAT_RGBA8)
				data = image.save_png_to_buffer()
			elif resource is AudioStream:
				match i.get_extension():
					"mp3":
						if OS.is_debug_build(): print("mp3:" + i)
						data = resource.get_data()
					"wav":
						## guzlad: CAN NOT BE format FORMAT_IMA_ADPCM or FORMAT_QOA as they don't support the save function
						## guzlad: Should be FORMAT_16_BITS like most of our other .wav files 
						if OS.is_debug_build(): print("wav:" + i)
						var wav_file: AudioStreamWAV = load(i)
						if !OS.is_debug_build():
							wav_file.save_to_wav(destination)
						else:
							print(error_string(wav_file.save_to_wav(destination)))
					## guzlad: No OGG yet
					_:
						data = resource.get_data()
		else:
			if OS.is_debug_build(): print("else:" + i)
			var old_file = FileAccess.open(i, FileAccess.READ)
			data = old_file.get_buffer(old_file.get_length())
			if OS.is_debug_build(): print("else error: " + error_string(old_file.get_error()))
			old_file.close()

		if !data.is_empty():
			if OS.is_debug_build(): print("saving:" + i)
			var new_file = FileAccess.open(destination, FileAccess.WRITE)
			new_file.store_buffer(data)
			if OS.is_debug_build(): print("saving error: " + error_string(new_file.get_error()))
			new_file.close()
	
	if (mode != TemplateMode.CHARACTER):
		var template_pack_info := resource_pack_base_info_json
		if (mode == TemplateMode.LEVEL_PACK):
			template_pack_info = level_pack_base_info_json
		
		var pack_info_path = new_path.path_join("pack_info.json")
		var file = FileAccess.open(pack_info_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(template_pack_info, "\t"))
		file.close()
	
	match(mode):
		TemplateMode.CHARACTER:
			print("Character got generated")
		TemplateMode.LEVEL_PACK:
			print("Level Pack got generated")
		TemplateMode.RESOURCE_PACK:
			print("Resource Pack got generated")
	template_created.emit(mode)

@warning_ignore("shadowed_variable")
func get_directories(base_dir := "", files := [], directories := []) -> void:
	directories.append(base_dir)
	get_files(base_dir, files)
	
	for i in DirAccess.get_directories_at(base_dir):
		if base_dir.contains("LevelGuides") == false and base_dir.contains(".godot") == false:
			get_directories(base_dir + "/" + i, files, directories)
	
	files.append("res://Assets/themes.json")

@warning_ignore("shadowed_variable")
func get_files(base_dir := "", files := []) -> void:
	for i in DirAccess.get_files_at(base_dir):
		if base_dir.contains("LevelGuides") == false:
			i = i.replace(".import", "")
			#print(i)
			var target_path = base_dir + "/" + i
			var rom_assets_path = target_path.replace("res://Assets", ModsLoader.resource_packs_path.path_join("BaseAssets"))
			if FileAccess.file_exists(rom_assets_path):
				files.append(rom_assets_path)
			else:
				files.append(target_path)

func download_file(file_path := "") -> PackedByteArray:
	var http = HTTPRequest.new()
	const GITHUB_URL = "https://raw.githubusercontent.com/JHDev2006/Super-Mario-Bros.-Remastered-Public/refs/heads/main/"
	var url = GITHUB_URL + file_path.replace("res://", "")
	add_child(http)
	http.request_completed.connect(handle_file_downloaded)
	http.request(url, [], HTTPClient.METHOD_GET)
	await file_downloaded
	http.queue_free()
	return downloaded_file

func handle_file_downloaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	downloaded_file = body
	file_downloaded.emit(downloaded_file)
