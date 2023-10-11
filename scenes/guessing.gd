extends Control

@onready var guess_1_button =  $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Guess 1"
@onready var guess_2_button =  $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Guess 2"
@onready var guess_3_button =  $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Guess 3"
@onready var guess_4_button =  $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Guess 4"
@onready var submit_button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer3/SubmitGuessButton
@onready var shame_label = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer4/ShameLabel
@onready var my_turn_label = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer5/MyTurnLabel
@onready var http = $HTTPRequest

var fake_q
var real_qs

var show_order
var buttons
var right_answer

var current_guess = 0

var submitted = false

var user_array
var user_submitted_array

func _ready():
	var current_player = Firebase.data_dict["current_question_player"]
	fake_q = Firebase.data_dict["submitted"][current_player]["fake"]
	real_qs = Firebase.data_dict["submitted"][current_player]["real"]
	show_order = real_qs + [fake_q]
	show_order.shuffle()
	buttons = [guess_1_button,guess_2_button,guess_3_button,guess_4_button]
	ReadFile.display_quote_order = [0,0,0,0]
	for i in range(4):
		if str(show_order[i]) == fake_q:
			ReadFile.display_quote_order[i] = fake_q
			buttons[i].text = add_line_breaks(fake_q, 85)
			right_answer = i
		else:
			ReadFile.display_quote_order[i] = ReadFile.quote_array[show_order[i]]
			buttons[i].text = add_line_breaks(ReadFile.quote_array[show_order[i]], 85)
	
	if current_player == Firebase.player_name: #it's my turn!
		current_guess = right_answer
		buttons[right_answer].disabled = true
		Firebase.submit_guess(http, current_guess, right_answer, true) #don't count score
		hide_buttons()
		my_turn_label.show()

func add_line_breaks(input_string: String, max_characters: int) -> String:
	var output_string = ""
	var current_line = ""
	var current_length = 0
	
	for word in input_string.split(" "):
		var word_length = word.length()
		
		if current_length + word_length <= max_characters:
			current_line += word + " "
			current_length += word_length + 1
		else:
			output_string += current_line.strip_edges() + "\n"
			current_line = word + " "
			current_length = word_length + 1
	
	output_string += current_line.strip_edges()
	return output_string
	


func _on_guess_1_pressed():
	buttons[current_guess].disabled = false
	current_guess = 0
	guess_1_button.disabled = true
	submit_button.show()
	

func _on_guess_2_pressed():
	buttons[current_guess].disabled = false
	current_guess = 1
	guess_2_button.disabled = true
	submit_button.show()

func _on_guess_3_pressed():
	buttons[current_guess].disabled = false
	current_guess = 2
	guess_3_button.disabled = true
	submit_button.show()

func _on_guess_4_pressed():
	buttons[current_guess].disabled = false
	current_guess = 3
	guess_4_button.disabled = true
	submit_button.show()

func _on_submit_guess_button_pressed():
	Firebase.submit_guess(http, current_guess, right_answer)
	submit_button.disabled = true


func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if submitted:
			if not Firebase.data_dict.has("guessed"):
				Firebase.get_dictionary(http)
			else:
				user_array = Firebase.data_dict["users"].keys()
				user_submitted_array = Firebase.data_dict["guessed"].keys()
				if user_array.size() == user_submitted_array.size():
					get_tree().change_scene_to_file("res://scenes/answer_check.tscn")
				else:
					_update_ui()
					Firebase.get_dictionary(http)
		else:
			submitted = true
			hide_buttons()
			submit_button.hide()
			Firebase.get_dictionary(http)
	else:
		submit_button.disabled = false

func hide_buttons():
	for button in buttons:
		if(button != buttons[current_guess]):
			button.disabled = true 
			button.set("theme_override_colors/font_disabled_color", Color(0.875, 0.875, 0.875))

func _update_ui():
	if(user_array.size() - user_submitted_array.size() == 1):
		shame_label.text = find_essay_writer() + " IS STILL GUESSING AN ESSAY"
	else:
		shame_label.text = str(user_array.size() - user_submitted_array.size()) + " PEOPLE ARE GUESSING ESSAYS"

func find_essay_writer():
	for user in user_array:
		if not user_submitted_array.has(user):
			return user
