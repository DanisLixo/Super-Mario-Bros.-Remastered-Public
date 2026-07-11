extends Node
const RESOURCE_PACK_CONTAINER = preload("uid://lggi3b4310yl")

var resource_packs := []
var containers := []

func _ready() -> void:
	get_resource_packs()

func open_folder() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(ModsLoader.resource_packs_path), true)

func get_resource_packs() -> void:
	for i in containers:
		get_parent().options.erase(i)
		i.queue_free()
	containers = []
	resource_packs = []
	for i in DirAccess.get_directories_at(ModsLoader.resource_packs_path):
		resource_packs.append(i)
	for i in resource_packs:
		var pack_info_path = ModsLoader.resource_packs_path.path_join(i + "/pack_info.json")
		if FileAccess.file_exists(pack_info_path) and i != Global.ROM_PACK_NAME:
			create_container(ModsLoader.resource_packs_path.path_join(i))

func create_container(resource_pack := "") -> void:
	var container = RESOURCE_PACK_CONTAINER.instantiate()
	container.pack_json = JSONParser.parse_to_dict(resource_pack + "/pack_info.json")
	if FileAccess.file_exists(resource_pack + "/config.json"):
		container.config = JSONParser.parse_to_dict(resource_pack + "/config.json")
		container.config_path = resource_pack + "/config.json"
	if FileAccess.file_exists(resource_pack + "/icon.png"):
		var image = Image.new()
		image.load(resource_pack + "/icon.png")
		container.icon = ImageTexture.create_from_image(image)
	elif FileAccess.file_exists(resource_pack + "/icon.gif"):
		container.icon = GifManager.animated_texture_from_file(resource_pack + "/icon.gif")
	container.pack_id = resource_pack.replace(ModsLoader.resource_packs_path, "").trim_prefix("/")
	$"../ScrollContainer/VBoxContainer".add_child(container)
	containers.append(container)
	container.add_to_group("Options")
	container.open_config.connect(owner.open_pack_config_menu)
	get_parent().options.append(container)
