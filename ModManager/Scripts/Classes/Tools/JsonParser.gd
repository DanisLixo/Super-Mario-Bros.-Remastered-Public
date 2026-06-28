class_name JSONParser extends Node

static func parse_json_to_dict(file_path: String) -> Dictionary:
	if (!FileAccess.file_exists(file_path)):
		printerr("\"%s\" is not a existing file!" % file_path)
		return {}
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if (file == null):
		var file_error := FileAccess.get_open_error()
		Global.log_error("File not opened, an error has occured.\nCODE: " + error_string(file_error))
		file.close()
		return {}
	
	var json_str := file.get_as_text()
	file.close()
	
	if file_path.contains("castle"):
		breakpoint
	
	return parse_string_to_dict(json_str)

static func parse_string_to_dict(json_str: String) -> Dictionary:
	var json_obj := JSON.new()
	var json_error = json_obj.parse(json_str)
	
	if (json_error == OK):
		return json_obj.data
	else:
		Global.log_error("Error parsing JSON! \"%s\" at line %s." % [json_obj.get_error_message(), json_obj.get_error_line()])
		return {}
