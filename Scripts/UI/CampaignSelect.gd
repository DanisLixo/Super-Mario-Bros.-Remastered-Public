extends Control

var selected_index := 0

signal selected
signal custom_selected
signal cancelled
var active := false

@export var campaign_icons: Array[Texture] = []

var old_campaign := ""

@export var campaign := ["SMB1", "SMBLL", "SMBS", "SMBANN", "Custom"]

var campaign_jsons := {}

static var custom_pack := ""

func _ready() -> void:
	Global.level_theme_changed.connect(update)
	
	import_level_packs()
	
	update()
	get_starting_position()
	handle_visuals()

func import_level_packs() -> void:
	LevelPacksHandler.get_level_packs()
	
	campaign.append_array(LevelPacksHandler.CUSTOM_CAMPAIGNS)
	campaign_icons.append_array(LevelPacksHandler.CUSTOM_CAMPAIGN_ICONS)
	
	for pack_folder in LevelPacksHandler.CUSTOM_CAMPAIGN_JSONS:
		var json = LevelPacksHandler.CUSTOM_CAMPAIGN_JSONS[pack_folder]
		
		var title: Label = %Custom.duplicate()
		if (json.is_empty()):
			Level.WORLD_COUNTS[pack_folder] = 1
			
			title.text = "ERROR!!!"
		else:
			Level.WORLD_COUNTS[pack_folder] = json.number_of_worlds
			
			title.text = json.name + "\nBy " + json.author
			title.add_theme_color_override("font_shadow_color", Color(json.text_colour))
		
		%CampaignNames.add_child(title)

func update() -> void:
	
	for icon in campaign_icons:
		if icon is AtlasTexture:
			icon.atlas = ResourceSetter.get_resource(load("res://Assets/Sprites/UI/CampaignIcons.png"), null, false, false)

func _process(_delta: float) -> void:
	if active:
		handle_input()
		handle_visuals()

func handle_visuals() -> void:
	%Left.texture = campaign_icons[wrap(selected_index - 1, 0, campaign_icons.size())]
	%Right.texture = campaign_icons[wrap(selected_index + 1, 0, campaign_icons.size())]
	%Middle.texture = campaign_icons[selected_index]
	%BarLabel.text = generate_text()
	for i in %CampaignNames.get_child_count():
		%CampaignNames.get_child(i).visible = selected_index == i

func generate_text() -> String:
	var string := ""
	string += "◄"
	for i in campaign.size():
		if i == selected_index:
			string += "┼"
		else:
			string += "-"
	string += "►"
	return string

func open() -> void:
	old_campaign = Global.current_campaign
	if Global.in_custom_campaign():
		old_campaign = Global.current_custom_campaign
	Global.current_game_mode = Global.GameMode.NONE
	get_starting_position()
	update()
	handle_visuals()
	show()
	await get_tree().process_frame
	active = true
	await selected
	hide()

func get_starting_position() -> void:
	if CustomLevelMenu.has_entered or selected_index == 4:
		selected_index = 4
	elif Global.in_custom_campaign():
		selected_index = campaign.find(Global.current_custom_campaign)
	else:
		selected_index = campaign.find(Global.current_campaign)

func handle_input() -> void:
	if Global.multibind_action_just_pressed("ui_left"):
		selected_index -= 1
		if Settings.file.audio.extra_sfx == 1:
			AudioManager.play_global_sfx("menu_move")
	if Global.multibind_action_just_pressed("ui_right"):
		selected_index += 1
		if Settings.file.audio.extra_sfx == 1:
			AudioManager.play_global_sfx("menu_move")
	selected_index = wrap(selected_index, 0, campaign.size())
	Global.current_campaign = campaign[selected_index]
	if Global.multibind_action_just_pressed("ui_accept"):
		select()
	elif Global.multibind_action_just_pressed("ui_back"):
		close()
		Global.current_campaign = old_campaign
		cancelled.emit()
		return

func select() -> void:
	CustomLevelMenu.has_entered = false
	Global.current_custom_campaign = ""
	var idx := 0
	for i in Settings.file.visuals.resource_packs:
		if i == Global.custom_pack:
			Settings.file.visuals.resource_packs.remove_at(idx)
		idx += 1
	if selected_index == 4:
		Global.current_campaign = "SMB1"
		Global.transition_to_scene("res://Scenes/Levels/CustomLevelMenu.tscn")
		return
	elif selected_index > 4:
		Global.current_custom_campaign = campaign[selected_index]
	active = false
	Settings.file.game.campaign = Global.current_campaign
	SaveManager.apply_save(SaveManager.load_save(campaign[selected_index]))
	if Global.current_campaign != "SMBANN" and Global.in_custom_campaign() == false:
		SpeedrunHandler.load_best_times()
	Settings.save_settings()
	if Global.in_custom_campaign():
		if LevelPacksHandler.CUSTOM_CAMPAIGN_JSONS[Global.current_custom_campaign].has("resource_pack"):
			var pack = LevelPacksHandler.CUSTOM_CAMPAIGN_JSONS[Global.current_custom_campaign].get("resource_pack", "")
			if pack == null:
				pack = ""
			Global.custom_pack = pack
		else:
			Global.custom_pack = ""
		Global.current_game_mode = Global.GameMode.CAMPAIGN
		if Global.custom_pack != "":
			if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(ModsLoader.resource_packs_path.path_join(Global.custom_pack))) == false:
				Global.log_error("Current campaign's resource pack was not found inside the resource packs folder.")
			else:
				Settings.file.visuals.resource_packs.push_front(Global.custom_pack)
		custom_selected.emit()
	else:
		Global.custom_pack = ""
		selected.emit()
	hide()
	if old_campaign != Global.current_campaign:
		Global.freeze_screen()
		ResourceSetter.cache.clear()
		ResourceSetterNew.clear_cache()
		ResourceGetter.cache.clear()
		Global.update_theme()
		Global.get_node("Transition").hide()
		for i in 2:
			await get_tree().process_frame
		Global.close_freeze()
	if Global.in_custom_campaign():
		Global.current_campaign = "SMB1"

func close() -> void:
	CustomLevelMenu.has_entered = false
	active = false
	hide()
