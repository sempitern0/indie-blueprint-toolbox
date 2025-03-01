@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintWindowManager", "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/autoload/window_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("IndieBlueprintWindowManager")
