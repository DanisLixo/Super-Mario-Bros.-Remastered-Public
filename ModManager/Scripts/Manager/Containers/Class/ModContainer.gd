extends Button
class_name ModContainer

const NO_ICON_IMAGE := preload("res://Assets/Sprites/UI/LevelPackIconEmpty.png")

signal selected(this: ModContainer)

@export var info_only := false
@export var enabled := true

var file_path := ""
var mod_id := ""
var json := {}

@export var idx := 0

func _ready() -> void:
	%Enabled.set_pressed_no_signal(enabled)
	
	set_process(false)
	update_visuals()
	
func _process(_delta: float) -> void:
	handle_visuals()
	
	if (Global.multibind_action_just_pressed("ui_accept") || Input.is_action_just_pressed("mb_left")) and visible:
		selected.emit(self)

func _physics_process(delta: float) -> void:
	handle_mod_activeness()

func update_visuals() -> void:
	%Enabled.visible = !info_only
	mouse_filter = Control.MOUSE_FILTER_STOP if info_only else Control.MOUSE_FILTER_IGNORE

func handle_visuals() -> void:
	pass

func handle_mod_activeness() -> void:
	pass
