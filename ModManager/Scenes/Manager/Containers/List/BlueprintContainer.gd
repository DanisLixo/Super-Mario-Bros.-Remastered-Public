class_name BlueprintContainer extends ModContainer

func update_visuals() -> void:
	%Name.text = file_path.get_file().to_upper()
