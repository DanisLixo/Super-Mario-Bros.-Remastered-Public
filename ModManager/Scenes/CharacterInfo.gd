extends VBoxContainer

func _ready() -> void:
	set_process(false)

func open(container: CustomLevelContainer = null) -> void:
	if container != null:
		for i in ["file_path", "mod_id", "json", "idx"]:
			%SelectedCharacter.set(i, container.get(i))
	%SelectedCharacter.update_visuals()
	
	%Description.text = tr(container.json.get("description", "MODS_NO_DESCRIPTION"))
	
	
	if (CharactersHandler.has_custom_physics()):
		%CharacterPhysics.text = tr("MODS_CHARACTER_HAS_PHYSICS")
	else:
		%CharacterPhysics.text = tr("MODS_CHARACTER_NO_PHYSICS")
