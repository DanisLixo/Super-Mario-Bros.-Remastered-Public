extends VBoxContainer

signal opened
signal closed

func _ready() -> void:
	close()

func _process(delta: float) -> void:
	if (Global.multibind_action_just_pressed("ui_back")):
		close()

func open() -> void:
	opened.emit()
	show()
	
	set_process(true)
	
	owner.update_path(false, "Manager")

func close(hide_section := true) -> void:
	if (hide_section):
		step_back()
	hide()
	owner.update_path(true)
		
	closed.emit()
	set_process(false)

func step_back() -> void:
	get_parent().hide()
	%SectionSelector.open()
