extends Node

@onready var quote_1_label = $"CanvasLayer/Control/VBoxContainer/MarginContainer3/VBoxContainer/Quote 1"
@onready var quote_2_label = $"CanvasLayer/Control/VBoxContainer/MarginContainer3/VBoxContainer/Quote 2"
@onready var quote_3_label = $"CanvasLayer/Control/VBoxContainer/MarginContainer3/VBoxContainer/Quote 3"
@onready var submitted_label = $"CanvasLayer/Control/VBoxContainer/MarginContainer3/VBoxContainer/Submitted Quote"

@onready var quote_entry = $CanvasLayer/Control/VBoxContainer/MarginContainer/QuoteEntry
@onready var submit_button = $CanvasLayer/Control/VBoxContainer/MarginContainer2/Button

@onready var http_pusher = $HTTPPusher
@onready var http_checker = $HTTPChecker

@onready var shame_label = $CanvasLayer/Control/VBoxContainer/ShameLabel

var user_array = []
var user_submitted_array = []

var submitted = false

func _ready():
	ReadFile.generate_turn_quotes()
	quote_1_label.text = ReadFile.get_turn_quote(0)
	quote_2_label.text = ReadFile.get_turn_quote(1)
	quote_3_label.text = ReadFile.get_turn_quote(2)
	Firebase.get_dictionary(http_checker)

func _on_button_pressed(): #submit
	Firebase.submit_fake_quote(http_pusher, quote_entry.text.strip_edges(), ReadFile.quote_numbers)
	submit_button.disabled = true


func _on_quote_entry_text_changed(new_text):
	var fake_quote = quote_entry.text.strip_edges()
	if fake_quote == "":
		submit_button.hide()
	else:
		submit_button.show()


func _on_http_pusher_request_completed(result, response_code, headers, body):
	if response_code == 200:
		submit_button.hide()
		quote_entry.hide()
		submitted_label.text = Firebase.player_fake_quote
		submitted_label.show()
		submitted = true
		shame_label.show()
	else:
		print(Firebase.json_to_response(body))
		submit_button.disabled = false


func _on_http_checker_request_completed(result, response_code, headers, body):
	var response = Firebase.json_to_response(body)
	if response_code == 200: #sick dawg
		user_array = response["users"].keys()
		if response.has("submitted"):
			user_submitted_array = response["submitted"].keys()
			if(submitted):
				if Firebase.is_host:
					Firebase.question_order_generated = false
				_update_ui()
			if user_array.size() == user_submitted_array.size():
				get_tree().change_scene_to_file("res://scenes/guessing_loading.tscn")
			else:
				Firebase.get_dictionary(http_checker)
		else:
			Firebase.get_dictionary(http_checker)
	else:
		Firebase.get_dictionary(http_checker)
		
func _update_ui():
	if(user_array.size() - user_submitted_array.size() == 1):
		shame_label.text = find_essay_writer() + " IS STILL WRITING AN ESSAY"
	else:
		shame_label.text = str(user_array.size() - user_submitted_array.size()) + " PEOPLE ARE WRITING ESSAYS"

func find_essay_writer():
	for user in user_array:
		if not user_submitted_array.has(user):
			return user
