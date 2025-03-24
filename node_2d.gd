extends Node2D


enum Category {
	Mage,
	Rogue
}

func _ready() -> void:
	print(IndieBlueprintEnumHelper.value_to_str(Category, 1))
	print(IndieBlueprintEnumHelper.values_to_str(Category))
