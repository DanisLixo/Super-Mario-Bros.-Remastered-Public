extends VBoxContainer

const GML_MOD_CONTAINER = preload("res://Scenes/Prefabs/UI/Mods/GMLModContainer.tscn")
const base64_charset := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

signal closed

var containers := []
var selected_mod_idx := -1
var search_check := ""

var mods_path = Global.config_path.path_join("mods")

var restart := true

func open(refresh_list := true) -> void:
	$"../../Title".text = tr("MOD_MANAGER")
	show()
	if refresh_list:
		refresh()
	if selected_mod_idx >= 0:
		%ModsContainers.get_child(selected_mod_idx).grab_focus()
	else:
		$SelectableLabel.grab_focus()
	await get_tree().process_frame
	set_process(true)

func open_folder() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(mods_path))

func _process(_delta: float) -> void:
	if (Global.multibind_action_just_pressed("ui_back") || Input.is_action_just_pressed("mb_right")) and CustomLineEdit.editing == false:
		closed.emit()

func close() -> void:
	$"../../Title".text = tr("CUSTOM_LEVELS")
	hide()
	set_process(false)

func refresh(move_mods := false) -> void:
	if (move_mods):
		for i in containers:
			if (i.enabled != i.actual_enabled):
				var move_to = i.file_path.replace(".disabled/", "")
				if (!i.enabled):
					move_to = i.file_path.replace("mods/", "mods/.disabled/")
				move_file(i.file_path, move_to)
		if (restart):
			$"../../../../../../GMLModsWarning".show()
			restart = false
	
	%ModsContainers.get_node("Label").show()
	for i in %ModsContainers.get_children():
		if i is GMLModContainer:
			i.queue_free()
	containers.clear()
	
	get_mods()
	get_mods(true)
	
func get_mods(disabled_list := false) -> void:
	var path: String = mods_path
	if disabled_list:
		path = mods_path.path_join(".disabled")
	var idx := 0
	for i in DirAccess.get_files_at(path):
		if i.contains(".zip") == false:
			continue
		%ModsContainers.get_node("Label").hide()
		
		var file_path = path + "/" + i
		var reader = ZIPReader.new()
		reader.open(file_path)
		var files = reader.get_files()
		var manifest_path := ""
		for j in files:
			if j.contains("manifest.json"):
				manifest_path = j
				break
		var json = reader.read_file(manifest_path).get_string_from_utf8()
		reader.close()
		
		var container = GML_MOD_CONTAINER.instantiate()
		container.idx = idx
		container.file_path = file_path
		container.manifest = JSON.parse_string(json)
		container.enabled = !disabled_list
		container.actual_enabled = !disabled_list
		
		container.selected.connect(container_selected)
		containers.append(container)
		[%EnabledGML, %DisabledGML][int(disabled_list)].show()
		
		%ModsContainers.add_child(container)
		%ModsContainers.move_child(container, [%EnabledGML, %DisabledGML][int(disabled_list)].get_index() + 1)
		idx += 1
		
const LEVEL_PACK_CONTAINER = preload("uid://buj10cxh15fnd")

func update_show(new_type := 0) -> void:
	for i in containers:
		i.visible = true
		if search_check != "" and i.visible:
			i.visible = i.manifest["name"].contains(search_check)
	
	#%EnabledGML.visible = get_visible_containers(int()) > 0
	#%DisabledGML.visible = get_visible_containers(CustomLevelContainer.Type.DOWNLOADED) > 0

func get_visible_containers(type := 0) -> int:
	var vis_child := 0
	for i in containers:
		if i.visible and i.current_type == type:
			vis_child += 1
	return vis_child

func search_submitted(search_query := "") -> void:
	search_check = search_query
	update_show()

func container_selected(container: CustomLevelContainer) -> void:
	# level_selected.emit(container)
	selected_mod_idx = container.get_index()

func move_file(path := "", move_to := "") -> void:
	var source := FileAccess.open(path, FileAccess.READ)
	
	if (source == null):
		Global.log_error("A GML mod was not located: " + path)
		return
	
	var pasted := FileAccess.open(move_to, FileAccess.WRITE)
	
	pasted.store_buffer(source.get_buffer(source.get_length()))
	
	source.close()
	pasted.close()
	
	DirAccess.remove_absolute(path)
