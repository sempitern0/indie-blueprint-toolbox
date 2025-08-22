class_name OmniKitHashSet extends RefCounted

var values: Array[Variant] = []


func _init(init_values: Array[Variant] = []) -> void:
	merge(init_values)


func merge(new_values: Array[Variant] = []) -> void:
	for value in new_values:
		add(value)

	
func add(value: Variant) -> void:
	if not has(value):
		values.append(value)
	
	
func duplicate() -> OmniKitHashSet:
	return OmniKitHashSet.new(values.duplicate())


func remove(value: Variant) -> void:
	values.erase(value)
		

func has(value: Variant) -> bool:
	return values.has(value)


func size() -> int:
	return values.size()


func equals(hashset: OmniKitHashSet) -> bool:
	if values.size() != hashset.size():
		return false
	
	var result: bool = true
	
	for value in values:
		if not hashset.has(value):
			result = false
			break
	
	return result


func clear() -> void:
	values.clear()
