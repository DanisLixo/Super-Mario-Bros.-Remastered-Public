extends Control

var selected_index := 0

signal selected
signal cancelled
var active := false

var player_id := 0

var character_sprite_jsons := [
	"res://Assets/Sprites/Players/Mario/Small.json",
	"res://Assets/Sprites/Players/Luigi/Small.json",
	"res://Assets/Sprites/Players/Toad/Small.json",
	"res://Assets/Sprites/Players/Toadette/Small.json"
]

const PLAYER_SCENE = "res://Scenes/Prefabs/Entities/Player.tscn"

func _process(_delta: float) -> void:
	if active:
		handle_input()

func _ready() -> void:
	update_sprites()

func open() -> void:
	CharactersHandler.get_custom_characters()
	show()
	selected_index = int(Global.player_characters[player_id])
	update_sprites()
	await get_tree().physics_frame
	grab_focus()
	active = true

func handle_input() -> void:
	if Global.multibind_action_just_pressed("ui_left"):
		selected_index = wrap(selected_index - 1, 0, CharactersHandler.CHARACTERS.size())
		update_sprites()
		if Settings.file.audio.extra_sfx == 1:
			AudioManager.play_global_sfx("menu_move")
	elif Global.multibind_action_just_pressed("ui_right"):
		selected_index = wrap(selected_index + 1, 0, CharactersHandler.CHARACTERS.size())
		update_sprites()
		if Settings.file.audio.extra_sfx == 1:
			AudioManager.play_global_sfx("menu_move")
	if Global.multibind_action_just_pressed("ui_accept"):
		Global.player_characters[player_id] = (selected_index)
		var characters: Array = Global.player_characters
		for i in characters:
			if int(i) > 3:
				characters = [0, 0, 0, 0]
		Settings.file.game.characters = characters
		Settings.save_settings()
		selected.emit()
		close()
	elif Global.multibind_action_just_pressed("ui_back"):
		close()
		cancelled.emit()

func update_sprites() -> void:
	%Left.force_character = CharactersHandler.CHARACTERS[wrap(selected_index - 1, 0, CharactersHandler.CHARACTERS.size())]
	%Selected.force_character = CharactersHandler.CHARACTERS[wrap(selected_index, 0, CharactersHandler.CHARACTERS.size())]
	%Right.force_character = CharactersHandler.CHARACTERS[wrap(selected_index + 1, 0, CharactersHandler.CHARACTERS.size())]
	for i in [%Left, %Selected, %Right]:
		i.update()
		i.play("Pose" if i == %Selected else "FaceForward")
	print(CharactersHandler.CHARACTER_COLOURS[selected_index])
	if (CharactersHandler.CHARACTER_COLOURS[selected_index] != null):
		%PlayerColourTexture.json_path = CharactersHandler.CHARACTER_COLOURS[selected_index]
	%CharacterName.text = tr(CharactersHandler.CHARACTER_NAMES[selected_index])
	$Panel/MarginContainer/VBoxContainer/CharacterName/TextShadowColourChanger/ColourPaletteSampler.texture = %ColourPaletteSampler.texture
	$Panel/MarginContainer/VBoxContainer/CharacterName/TextShadowColourChanger.handle_shadow_colours()

func select() -> void:
	selected.emit()
	hide()
	active = false

func close() -> void:
	active = false
	hide()


func on_selected() -> void:
	pass # Replace with function body.
