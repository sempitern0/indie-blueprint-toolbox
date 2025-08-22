## A class for generating new text (like words or names) based on patterns
## learned from a provided training dataset. It uses a Markov chain model to predict
## the next character in a sequence, creating plausible-sounding outputs.
class_name OmniKitMarkovChainTextGenerator extends RefCounted


const CHARACTERS: Array[String] = [
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", 
	"k", "l", "m", "n", "o", "p", "q", "r", "s", "t", 
	"u", "v", "w", "x", "y", "z", "â", "à", "é", "è", 
	"ê", "ë", "î", "ï", "ô", "ö", "ù", "û", "ç", " ", 
	"-", ".", "0", "1", "2", "3", "4", "5", "6", "7", 
	"8", "9", "á", "é", "í", "ó", "ú", "ñ", "ü", "ø", 
	"æ", "œ", "ß", "'", "_", "&", "#", "@", "!", "?"
]

var trigram_frequencies: Dictionary
var total_trigram_count: int
var training_data: Array
var start_pattern_counts : Dictionary[String, int]
var end_pattern_counts: Dictionary[String, int]


func _init(training_items: Array, chain_depth: int = 2): ## chain_depth is not being used as this would need a good refactor
	trigram_frequencies = {}
	
	for c1 in CHARACTERS:
		var d2 = {}
		
		for c2 in CHARACTERS:
			var d3 = {}
			
			for c3 in CHARACTERS:
				d3[c3] = 0.0
			d2[c2] = d3
			
		trigram_frequencies[c1] = d2

	total_trigram_count = 0
	start_pattern_counts  = {}
	end_pattern_counts = {}

	for item: String in training_items:
		var processed_item: String = item.strip_edges().to_lower()
		training_data.append(item)

		for c in range(processed_item.length() - 2):
			if c == 0:
				var start_segment = processed_item.substr(0, min(3, processed_item.length()))
				
				if start_segment in start_pattern_counts:
					start_pattern_counts[start_segment] += 1
				else: 
					start_pattern_counts[start_segment] = 1
			
			if c == processed_item.length() - 3:
				var end_segment  = processed_item.substr(c)
				
				if end_segment .length() > 0:
					if end_segment  in end_pattern_counts: 
						end_pattern_counts[end_segment ] += 1
					else: 
						end_pattern_counts[end_segment ] = 1
			
			var char_a = processed_item[c]
			var char_b = processed_item[c + 1]
			var char_c = processed_item[c + 2]
			
			if (not (char_a in trigram_frequencies) or \
				not (char_b in trigram_frequencies[char_a]) or \
				not (char_c in trigram_frequencies[char_a][char_b])): 
				continue
				
			trigram_frequencies[processed_item[c]][char_b][char_c] += 1
			total_trigram_count += 1


func generate(must_be_new: bool = true, max_output_length: int = 10, end_probability_threshold: float = 0.75, generation_attempt: int = 0) -> String:
	var result = get_weighted_random_item(start_pattern_counts ).pick_random()

	var current_index: int = 3
	var pattern: String
	var possible_next_chars: Array
	var next_char: String
	
	while result.length() < max_output_length:
		if (not result[current_index - 2] in trigram_frequencies or \
			not result[current_index - 1] in trigram_frequencies[result[current_index - 2]]): 
				break

		possible_next_chars = get_weighted_random_item(trigram_frequencies[result[current_index - 2]][result[current_index - 1]])
		
		if possible_next_chars.is_empty():
			break

		next_char = possible_next_chars.pick_random()
		result += next_char
		pattern = result.substr(result.length() - 3)

		if pattern in end_pattern_counts:
			if end_pattern_counts[pattern] > 0.001:
				if randf() < end_probability_threshold: break

		current_index += 1


	if not ["a", "e", "i", "o", "u", "y"].any(func(vowel: String): return vowel in result):
		result = generate(must_be_new, max_output_length, end_probability_threshold, generation_attempt + 1)

	if generation_attempt < 100:

		if result.length() > 3:
			while (not result.substr(max(0, result.length() - 3)) in end_pattern_counts):
				result = result.substr(0, result.length() - 1)
				
				if result.is_empty():
					result = generate(must_be_new, max_output_length, end_probability_threshold, generation_attempt + 1)

		var cleaned_parts: Array = (result.split(" ") as Array).filter(func(p): return p.length() > 1)
		result = " ".join(cleaned_parts)

		if must_be_new and result in training_data:
			result = generate(must_be_new, max_output_length, end_probability_threshold, generation_attempt + 1)

	return result.capitalize()


func get_weighted_random_item(data: Dictionary):
	var items = []
	
	for key in data:
		for i in range(data[key]):
			items.append(key)
			
	return items
