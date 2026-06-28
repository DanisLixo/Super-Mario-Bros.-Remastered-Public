extends VBoxContainer

signal opened
signal closed

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if (Global.multibind_action_just_pressed("ui_back")):
		close()
		owner.go_to_title_screen()

func wiki_pressed() -> void:
	open_wiki_page()

func open_wiki_page() -> void:
	AudioManager.play_global_sfx("score_end")
	OS.shell_open("https://github.com/JHDev2006/Super-Mario-Bros.-Remastered-Public/wiki")
	
	owner.wiki_path_anim()

func open() -> void:
	opened.emit()
	show()
	
	set_process(true)

func close() -> void:
	hide()
	
	closed.emit()
	set_process(false)
