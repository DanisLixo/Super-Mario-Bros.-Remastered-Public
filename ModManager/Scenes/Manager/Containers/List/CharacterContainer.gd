class_name ModCharacterContainer extends ModContainer

func _ready() -> void:
	super()
	
	focus_entered.connect(handle_focus)
	focus_exited.connect(handle_focus)

func update_visuals() -> void:
	super()
	
	update_sprites()
	
	%Name.text = tr(CharactersHandler.CHARACTER_NAMES[idx])
	%TextShadowColourChanger.handle_shadow_colours()
	
	%Author.text = CharactersHandler.CHARACTER_AUTHORS[idx]
	%ID.text = mod_id

func update_sprites() -> void:
	%Character.force_character = mod_id
	%Character.update()
	%Character.play("FaceForward")
	
	%CharacterIcon.get_node("ResourceSetterNew").resource_json = (CharactersHandler.CHARACTER_ICONS[idx])
	
	%PlayerColourTexture.resource_json = CharactersHandler.CHARACTER_COLOURS[idx]
	%NameColourPaletteSampler.texture = %SpotlightColourPaletteSampler.texture

func handle_mod_activeness() -> void:
	super()
	
	enabled = %Enabled.button_pressed
	
	material.set_shader_parameter("enabled", !enabled)

func handle_focus() -> void:
	if (has_focus() && enabled):
		%Character.play("Pose")
	else:
		%Character.play("FaceForward")
