class_name GMLContainer extends ModContainer

var current_activeness := true

func update_visuals() -> void:
	%Thumbnail.texture = get_image()
	
	if (json.is_empty()):
		return
	
	%Name.text = json["name"]
	%Author.text = json["namespace"]

func get_image() -> Texture2D:
	if (GMLHandler.GML_MOD_ICONS[idx] != null):
		return GMLHandler.GML_MOD_ICONS[idx]
	else:
		return ModContainer.NO_ICON_IMAGE
