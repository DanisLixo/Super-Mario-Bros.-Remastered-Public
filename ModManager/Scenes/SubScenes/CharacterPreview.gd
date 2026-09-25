extends Control

@export var character_id := 0: set = update_sprite

var selected_anim := 0
var animation_list := []

# Hey gezonde, not implying anything but if you want to...
var selected_power_state := 0
var power_states := ["Small", "Big", "Fire"]

var current_speed := 1.0

signal opened
signal closed

func _ready() -> void:
	CharactersHandler.get_custom_characters(true)
	Global.hide_hud()

func _process(delta: float) -> void:
	handle_inputs()
	update()

func update() -> void:
	%CurrentAnimation.text = animation_list[selected_anim]
	%CurrentPowerState.text = power_states[selected_power_state]
	%Zoom.text = str(%PlayerSprite.scale.x)
	%Speed.text = str(current_speed)
	
	if (%PlayerSprite.is_playing()):
		%AnimLabel.text = "Stop Animation"
	else:
		%AnimLabel.text = "Play Animation"
	
	update_sprite(character_id)

func update_sprite(value := 0) -> void:
	var was_playing = %PlayerSprite.is_playing()
	
	character_id = value
	
	%PlayerSprite.force_character = CharactersHandler.CHARACTERS[character_id]
	
	%PlayerSprite.force_power_state = str(selected_power_state)
	%PlayerSprite.update()
	
	animation_list = Array(%PlayerSprite.sprite_frames.get_animation_names().duplicate())
	%PlayerSprite.animation = animation_list[selected_anim]
	
	%PlayerSprite.speed_scale = current_speed
	
	if (!was_playing):
		%PlayerSprite.stop()
	%PlayerSprite.sprite_frames.set_animation_loop(animation_list[selected_anim], looping)

func open(container: ModCharacterContainer = null) -> void:
	show()
	opened.emit()
	
	var new_id := 0
	if (container != null):
		new_id = container.idx
	
	update_sprite(new_id)
	
	set_process(false)
	await get_tree().process_frame
	set_process(true)

func close() -> void:
	hide()
	closed.emit()
	set_process(false)

func handle_inputs() -> void:
	var spr_pos_input := Input.get_vector("editor_cam_right", "editor_cam_left", "editor_cam_down", "editor_cam_up")
	if (spr_pos_input != Vector2.ZERO):
		var vec_mult := 3 if (Input.is_action_pressed("editor_cam_fast")) else 1
		%PlayerSprite.position += spr_pos_input * vec_mult
		
		var far_left_position := -(get_viewport_rect().size / 2) + Vector2(20, 20)
		var far_right_position := get_viewport_rect().size - Vector2(20, 20)
		
		%PlayerSprite.position.x = clamp(%PlayerSprite.position.x, far_left_position.x, far_right_position.x)
		%PlayerSprite.position.y = clamp(%PlayerSprite.position.y, far_left_position.y, far_right_position.y)
		
	var spd_input := int(Global.multibind_action_just_pressed("preview_speed_increase")) - int(Global.multibind_action_just_pressed("preview_speed_decrease"))
	if (spd_input != 0):
		AudioManager.play_global_sfx("menu_move")
		
		current_speed += spd_input * 0.1
		current_speed = clampf(current_speed, 0.1, 10.0)
		current_speed = snappedf(current_speed, 0.01)
	
	var zoom_input := int(Global.multibind_action_just_pressed("editor_zoom_in")) - int(Global.multibind_action_just_pressed("editor_zoom_out"))
	if (zoom_input != 0):
		AudioManager.play_global_sfx("menu_move")
		
		%PlayerSprite.scale += Vector2.ONE * zoom_input * 0.1
		%PlayerSprite.scale = clamp(%PlayerSprite.scale, Vector2.ONE * 0.3, Vector2.ONE * 10.0)
		%PlayerSprite.scale.x = snappedf(%PlayerSprite.scale.x, 0.01)
		%PlayerSprite.scale.y = snappedf(%PlayerSprite.scale.y, 0.01)

	var anim_input := int(Global.multibind_action_just_pressed("ui_right")) - int(Global.multibind_action_just_pressed("ui_left"))
	if (anim_input != 0):
		AudioManager.play_global_sfx("menu_move")
		
		selected_anim += anim_input
		selected_anim = wrap(selected_anim, 0, animation_list.size())
	
	var ps_input := int(Global.multibind_action_just_pressed("ui_down")) - int(Global.multibind_action_just_pressed("ui_up"))
	if (ps_input != 0):
		AudioManager.play_global_sfx("menu_move")
		
		selected_power_state += ps_input
		selected_power_state = wrap(selected_power_state, 0, power_states.size())

func play_animation() -> void:
	if (!%PlayerSprite.is_playing()):
		%PlayerSprite.play()
	else:
		%PlayerSprite.stop()

func frame_backward() -> void:
	%PlayerSprite.speed_scale = -abs(%PlayerSprite.speed_scale)
	
	var current_frame = %PlayerSprite.frame
	current_frame -= 1
	%PlayerSprite.frame = wrapi(current_frame, 0, %PlayerSprite.sprite_frames.get_frame_count(animation_list[selected_anim]))

func frame_forward() -> void:
	%PlayerSprite.speed_scale = abs(%PlayerSprite.speed_scale)
	
	var current_frame = %PlayerSprite.frame
	current_frame += 1
	%PlayerSprite.frame = wrapi(current_frame, 0, %PlayerSprite.sprite_frames.get_frame_count(animation_list[selected_anim]))

var looping := true
func toggle_loop() -> void:
	looping = !looping

	%PlayerSprite.sprite_frames.set_animation_loop(animation_list[selected_anim], looping)
	
	%LoopLabel.text = "Loop: " + str(looping)
