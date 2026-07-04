class_name CharactersHandler extends Node

const DEFAULT_CHARACTERS := ["Mario", "Luigi", "Toad", "Toadette"]
const DEFAULT_CHARACTER_NAMES := ["CHAR_MARIO", "CHAR_LUIGI", "CHAR_TOAD", "CHAR_TOADETTE"]
const DEFAULT_CHARACTER_AUTHORS := ["NINTENDO", "NINTENDO", "NINTENDO", "NINTENDO"]
const DEFAULT_CHARACTER_COLOURS := [
	("res://Assets/Sprites/Players/Mario/CharacterColour.json"), 
	("res://Assets/Sprites/Players/Luigi/CharacterColour.json"), 
	("res://Assets/Sprites/Players/Toad/CharacterColour.json"), 
	("res://Assets/Sprites/Players/Toadette/CharacterColour.json")
]
const DEFAULT_CHARACTER_PALETTES := [
	("res://Assets/Sprites/Players/Mario/ColourPalette.json"),
	("res://Assets/Sprites/Players/Luigi/ColourPalette.json"),
	("res://Assets/Sprites/Players/Toad/ColourPalette.json"),
	("res://Assets/Sprites/Players/Toadette/ColourPalette.json")
]
const DEFAULT_CHARACTER_ICONS := [
	("res://Assets/Sprites/Players/Mario/LifeIcon.json"),
	("res://Assets/Sprites/Players/Luigi/LifeIcon.json"),
	("res://Assets/Sprites/Players/Toad/LifeIcon.json"),
	("res://Assets/Sprites/Players/Toadette/LifeIcon.json")
]

const DEFAULT_PHYSICS_PARAMETERS: Dictionary = {
	"Default": { # Fallback parameters. Additional entries can be added through CharacterInfo.json.
		"COLLISION_SIZE": [8, 28],
		"CROUCH_COLLISION_SIZE": [8, 14],            # The player's hitbox scale when crouched.
		"CAN_AIR_TURN": false,             # Determines if the player can turn in mid-air.
		"CAN_BREAK_BRICKS": true,          # Determines if the player can break bricks in their current form.
		"CAN_BE_WALL_EJECTED": true,       # Determines if the player gets pushed out of blocks if inside of them.
		"ROUNDED_FLOOR_COLLISION": false,
		"JUMP_WALK_THRESHOLD": 60.0,       # The minimum velocity the player must move at to perform a walking jump.
		"JUMP_RUN_THRESHOLD": 135.0,       # The minimum velocity the player must move at to perform a running jump.
		
		"JUMP_GRAVITY_IDLE": 11.0,         # The player's gravity while jumping from an idle state, measured in px/frame.
		"JUMP_GRAVITY_WALK": 11.0,         # The player's gravity while jumping from a walking state, measured in px/frame.
		"JUMP_GRAVITY_RUN": 11.0,          # The player's gravity while jumping from a running state, measured in px/frame.
		"JUMP_SPEED_IDLE": 300.0,          # The strength of the player's idle jump, measured in px/sec.
		"JUMP_SPEED_WALK": 300.0,          # The strength of the player's walking jump, measured in px/sec.
		"JUMP_SPEED_RUN": 300.0,           # The strength of the player's running jump, measured in px/sec.
		"JUMP_INCR": 8.0,                  # How much the player's X velocity affects their jump speed.
		"JUMP_CANCEL_DIVIDE": 1.5,         # When the player cancels their jump, their Y velocity gets divided by this value.
		"JUMP_HOLD_SPEED_THRESHOLD": 0.0,  # When the player's Y velocity goes past this value while jumping, their gravity switches to FALL_GRAVITY.
		"JUMP_BUFFER": 10,
		"CLASSIC_BOUNCE_BEHAVIOR": false,  # Determines if the player can only get extra height from a bounce with upward velocity, as opposed to holding jump.
		"BOUNCE_SPEED": 200.0,             # The strength at which the player bounces off enemies without any extra input, measured in px/sec.
		"BOUNCE_JUMP_SPEED": 300.0,        # The strength at which the player bounces off enemies while holding jump, measured in px/sec.
		
		"FALL_GRAVITY_PREDETERMINED": false,         # Determines if the player's gravity is determined by their last X velocity from leaving the ground rather than their current X velocity.
		"FALL_GRAVITY_IDLE": 25.0,         # The player's gravity while falling from an idle state, measured in px/frame.
		"FALL_GRAVITY_WALK": 25.0,         # The player's gravity while falling from a walking state, measured in px/frame.
		"FALL_GRAVITY_RUN": 25.0,          # The player's gravity while falling from a running state, measured in px/frame.
		"MAX_FALL_SPEED": 280.0,           # The player's maximum fall speed, measured in px/sec.
		"CEILING_BUMP_SPEED": 45.0,        # The speed at which the player falls after hitting a ceiling, measured in px/sec.
		
		"CLAMP_GROUND_SPEED": false,       # Determines if the player's speed will get clamped while moving on the ground, emulating snappier movement.
		"MINIMUM_SPEED": 0.0,              # The player's minimum speed while actively moving.
		
		"WALK_SPEED": 96.0,                # The player's speed while walking, measured in px/sec.
		"GROUND_WALK_ACCEL": 4.0,          # The player's acceleration while walking, measured in px/frame.
		"WALK_SKID": 8.0,                  # The player's turning deceleration while running, measured in px/frame.
		"CAN_RUN_ACCEL_EARLY": false,      # Determines if the player can hold run before reaching walk speed to begin running.
		"RUN_STOP_BUFFER": 0.0,            # Determines the amount of time in seconds before running will stop once its initiated.
		"RUN_SPEED": 160.0,                # The player's speed while running, measured in px/sec.
		"GROUND_RUN_ACCEL": 1.25,          # The player's acceleration while running, measured in px/frame.
		"RUN_SKID": 8.0,     
		"ICE_ACCEL_MOD": 0.25,
		"ICE_DECEL_MOD": 0.25,
		"ICE_SKID_MOD": 0.25,              # The player's turning deceleration while running, measured in px/frame.
		
		"CLASSIC_SKID_CONDITIONS": false,  # Determines if the player's speed must be over SKID_THRESHOLD to begin skidding.
		"CAN_INSTANT_STOP_SKID": false,    # Determines if the player will instantly stop upon reaching the skid threshold.
		"SKID_THRESHOLD": 100.0,           # The horizontal speed required, to be able to start skidding.
		"SKID_STOP_THRESHOLD": 10.0,       # The maximum velocity required before the player will stop skidding.
		
		"GROUND_WALK_DECEL": 3.0,          # The player's grounded deceleration while no buttons are pressed, measured in px/frame.
		"GROUND_RUN_DECEL": 3.0,           # The player's grounded deceleration while no buttons are pressed from running speed, measured in px/frame.
		"DECEL_THRESHOLD": 0,
		"AIR_DECEL": 0.0,                  # The player's airborne deceleration while no buttons are pressed, measured in px/frame.
		
		"AIR_WALK_ACCEL": 3.0,             # The player's usual acceleration while in midair, measured in px/frame.
		"AIR_WALK_SKID_ACCEL": 4.5,        # The player's usual skid acceleration while in midair, measured in px/frame.
		"AIR_RUN_ACCEL": 3.0,              # The player's running acceleration while in midair, measured in px/frame.
		"AIR_RUN_SKID_ACCEL": 4.5,         # The player's running skid acceleration while in midair, measured in px/frame.
		"AIR_BACKWARDS_ACCEL": 3.0,        # The player's backwards acceleration while in midair, measured in px/frame.
		"AIR_BACKWARDS_SKID_ACCEL": 4.5,   # The player's backwards skid acceleration while in midair, measured in px/frame.
		"AIR_SKID_JUMP_SPEED_MINIMUM": 0.0,          # The minimum jump speed required to use 'skid' params instead of 'accel' params for air control.

		"LOCK_AIR_SPEED": false,           # Determines if the player can surpass their walk speed while in the air, aside from on trampolines.
		"USE_BACKWARDS_ACCEL": false,      # Determines if the player will use backwards acceleration while travelling backwards.
		"CAN_AIR_RUN_WITHOUT_RUN_BUTTON": false,     # Determines if the player must be holding the run button to allow for running speed in the air.
		"CAN_AIR_SKID_ALWAYS": true,       # Determines if the player uses 'skid' params instead of 'accel' params if jump started below a certain speed.
		"CAN_AIR_RUN_EARLY": false,        # Determines a multiplier to the player's acceleration when moving backwards in the air.
		
		"CLIMB_OFFSET": 5.0,               # The X position offset applied to the player when climbing.
		"CLIMB_UP_SPEED": 50.0,            # The player's speed while climbing upwards, measured in px/sec.
		"CLIMB_DOWN_SPEED": 120.0,         # The player's speed while climbing downwards, measured in px/sec.

		"TRAMPOLINE_SPEED": 500.0,         # The strength of a jump on a trampoline, measured in px/sec.
		"SUPER_TRAMPOLINE_SPEED": 1200.0,  # The strength of a jump on a super trampoline, measured in px/sec.
		
		"SWIM_SPEED": 95.0,                # The player's horizontal speed while swimming, measured in px/sec.
		"SWIM_GROUND_SPEED": 45.0,         # The player's horizontal speed while grounded underwater, measured in px/sec.
		"SWIM_DECEL": 3.0,                 # The player's deceleration in water while no buttons are pressed, measured in px/frame.
		"SWIM_HEIGHT": 100.0,              # The strength of the player's swim, measured in px/sec.
		"SWIM_EXIT_SPEED": 250.0,          # The strength of the player's jump out of water, measured in px/sec.
		"SWIM_GRAVITY": 2.5,               # The player's gravity while swimming, measured in px/frame.
		"MAX_SWIM_FALL_SPEED": 200.0,      # The player's maximum fall speed while swimming, measured in px/sec.
	},
	"Small": {
		"COLLISION_SIZE": [8, 14],
		"CROUCH_COLLISION_SIZE": [8, 12],
		"CAN_BREAK_BRICKS": false,
		"CAN_BE_WALL_EJECTED": false,
	},
	"Big": {},
	"Fire": {},
	"Superball": {}
}

# I decided to put all characters arrays inside the handler so everything is within the handler...
static var CHARACTERS := DEFAULT_CHARACTERS.duplicate()
static var CHARACTER_NAMES := DEFAULT_CHARACTER_NAMES.duplicate()
static var CHARACTER_AUTHORS := DEFAULT_CHARACTER_AUTHORS.duplicate()
static var CHARACTER_COLOURS := DEFAULT_CHARACTER_COLOURS.duplicate()
static var CHARACTER_PALETTES := DEFAULT_CHARACTER_PALETTES.duplicate()
static var CHARACTER_ICONS := DEFAULT_CHARACTER_ICONS.duplicate()

static var disabled_mods := []

# This includes Character Select's get_custom_characters method.
static func get_custom_characters(deep := false) -> void:
	clear_characters_list()
	
	apply_resource_pack_changes()
	
	var char_dir = ModsLoader.characters_path
	for i in DirAccess.get_directories_at(char_dir):
		var char_path = char_dir.path_join(i)
		var char_info_path = char_path.path_join("CharacterInfo.json")
		
		if (!deep):
			if (disabled_mods.has(i)):
				continue
		if !FileAccess.file_exists(char_info_path):
			continue
		
		var json := JSONParser.parse_json_to_dict(char_path.path_join("CharacterInfo.json"))
		
		if json.has("physics"):
			if json.physics.has("PHYSICS_PARAMETERS") == false:
				json = CustomCharacterUpdater.update_json(json)
				Global.log_comment("Updated CharacterInfo for: " + i)
				FileAccess.open(char_path.path_join("CharacterInfo.json"), FileAccess.WRITE).store_string((JSON.stringify(json, "\t", false)))
		
		import_character(i, char_path, json)

static func import_character(char_id := "", char_path := "", char_json := {}) -> void:
	CHARACTERS.append(char_id)
	if (char_json.has("name")):
		CHARACTER_NAMES.append(char_json.name)
	else:
		CHARACTER_NAMES.append("NAME NOT SET")
	if (char_json.has("author")):
		CHARACTER_AUTHORS.append(char_json.author)
	else:
		CHARACTER_AUTHORS.append("UNKNOWN")
	
	if FileAccess.file_exists(char_path.path_join("CharacterColour.json")):
		CHARACTER_COLOURS.append((char_path.path_join("CharacterColour.json")))
	else:
		CHARACTER_COLOURS.append(null)
	
	if FileAccess.file_exists(char_path.path_join("LifeIcon.json")):
		CHARACTER_ICONS.append((char_path.path_join("LifeIcon.json")))
	else:
		CHARACTER_ICONS.append(null)
		
	if FileAccess.file_exists(char_path.path_join("ColourPalette.json")):
		CHARACTER_PALETTES.append((char_path.path_join("ColourPalette.json")))
	else:
		CHARACTER_PALETTES.append(null)
	
	AudioManager.character_sfx_map[char_id] = JSONParser.parse_json_to_dict(char_path.path_join("SFX.json"))

static func clear_characters_list() -> void:
	CHARACTERS = DEFAULT_CHARACTERS.duplicate()
	CHARACTER_NAMES = DEFAULT_CHARACTER_NAMES.duplicate()
	CHARACTER_AUTHORS = DEFAULT_CHARACTER_AUTHORS.duplicate()
	CHARACTER_COLOURS = DEFAULT_CHARACTER_COLOURS.duplicate()
	CHARACTER_PALETTES = DEFAULT_CHARACTER_PALETTES.duplicate()
	CHARACTER_ICONS = DEFAULT_CHARACTER_ICONS.duplicate()
	AudioManager.character_sfx_map.clear()

static func apply_resource_pack_changes():
	for i in DEFAULT_CHARACTERS.size():
		var character: String = CHARACTERS[i]
		
		var path = ResourceSetter.get_pure_resource_path("res://Assets/Sprites/Players/" + character + "/CharacterInfo.json")
		if FileAccess.file_exists(path):
			var json = JSONParser.parse_json_to_dict(path)
			if (json.has("name")):
				CHARACTER_NAMES[i] = json.name
		path = ResourceSetter.get_pure_resource_path("res://Assets/Sprites/Players/" + character + "/CharacterColour.json")
		if FileAccess.file_exists(path):
			CHARACTER_COLOURS[i] = (path)

static func has_custom_physics(parameters := {}) -> bool:
	return DEFAULT_PHYSICS_PARAMETERS == parameters
	
