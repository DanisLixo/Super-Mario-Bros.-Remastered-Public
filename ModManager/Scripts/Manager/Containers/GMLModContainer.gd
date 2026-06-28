extends ModContainer
class_name GMLModContainer

var current_activeness := true

func update_visuals() -> void:
	%Enabled.set_pressed_no_signal(enabled)
	
	if (json.is_empty()):
		return
	
	%ModName.text = json["name"]
	%ModAuthor.text = json["namespace"]
	%ModDesc.text = json["description"]
	
	%Thumbnail.texture = import_image()

func import_image() -> Texture:
	var texture := load("res://Assets/Sprites/UI/LevelPackIconEmpty.png")
	var image := get_image()
	if (image != null):
		texture = ImageTexture.create_from_image(image)
	return texture

func get_image() -> Image:
	var path = ModsLoader.gml_path
	
	var image := Image.new()
	
	var reader := ZIPReader.new()
	reader.open(path.path_join(mod_id))
	
	var image_path := ""
	for i in reader.get_files():
		if i.contains("icon.png"):
			image_path = i
			break
	if (!reader.file_exists(image_path)):
		return null
	
	var bytes = reader.read_file(image_path)
	reader.close()
	
	if !bytes.is_empty():
		image.load_png_from_buffer(bytes)
		
	return image
