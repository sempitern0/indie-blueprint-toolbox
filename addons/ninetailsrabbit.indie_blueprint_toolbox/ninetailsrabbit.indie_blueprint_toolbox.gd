@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintWindowManager", "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/autoloads/viewport/window_manager.gd")
	add_custom_type(
		"IndieBlueprintSmartDecal", 
		"Decal", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/3D/decals/smart_decal.gd"),
		null
	)


func _exit_tree() -> void:
	remove_custom_type("SmartDecal")
	remove_autoload_singleton("IndieBlueprintWindowManager")
