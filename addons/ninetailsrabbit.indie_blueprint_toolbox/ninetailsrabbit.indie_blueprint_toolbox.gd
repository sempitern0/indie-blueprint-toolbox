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
	
	add_custom_type(
		"IndieBlueprintDraggable2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("IndieBlueprintDraggable2D")
	remove_custom_type("SmartDecal")
	remove_autoload_singleton("IndieBlueprintWindowManager")
