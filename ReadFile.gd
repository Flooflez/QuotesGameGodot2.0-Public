extends Node

var quote_array = []

var quote_numbers = []

var display_quote_order = []

func exists():
	return FileAccess.file_exists("user://quotes.txt")
	
func validate():
	var file = FileAccess.open("user://quotes.txt", FileAccess.READ)
	var content = file.get_as_text()
	if content == "" or content == " --- DELETE THIS LINE AND PASTE QUOTES HERE --- ":
		return false
	return true

func create_empty():
	var file = FileAccess.open("user://quotes.txt", FileAccess.WRITE)
	file.store_string(" --- DELETE THIS LINE AND PASTE QUOTES HERE --- ")

func generate_array():
	var file = FileAccess.open("user://quotes.txt", FileAccess.READ)
	quote_array = file.get_as_text().split("\n")

func generate_turn_quotes():
	quote_numbers = []
	for i in range(3):
		var temp = randi() % quote_array.size()
		while quote_numbers.has(temp):
			temp = randi() % quote_array.size()
		quote_numbers += [temp]

func get_turn_quote(number):
	return quote_array[quote_numbers[number]]
