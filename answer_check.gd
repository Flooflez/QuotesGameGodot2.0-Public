extends Control

@onready var quote_1_label = $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Quote 1"
@onready var quote_2_label = $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Quote 2"
@onready var quote_3_label = $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Quote 3"
@onready var quote_4_label = $"CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/Quote 4"

@onready var next_button = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer3/NextButton
@onready var not_host_label = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer4/NotHostLabel
@onready var my_turn_label = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer5/MyTurnLabel

@onready var http = $HTTPRequest
@onready var http_not_host = $HTTPRequestNotHost

var awarded

func _ready():
	var quotes = [quote_1_label,quote_2_label,quote_3_label,quote_4_label]
	for i in range(4):
		quotes[i].text = ReadFile.display_quote_order[i]
	quotes[Firebase.curr_guess].set("theme_override_colors/font_color", Color(0.875, 0.1, 0))
	quotes[Firebase.answer].set("theme_override_colors/font_color", Color(0, 0.875, 0))
	if Firebase.is_host:
		Firebase.award_points(http)
	else:
		not_host_label.show()
		Firebase.get_dictionary(http_not_host)

	if Firebase.data_dict["current_question_player"] == Firebase.player_name:
		my_turn_label.show()


func _on_next_button_pressed():
	Firebase.clear_guesses(http)


func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if awarded:
			Firebase.data_dict.erase("guessed")
			if Firebase.current_q_index == Firebase.question_order.size(): #end of turn
				get_tree().change_scene_to_file("res://scenes/scores.tscn")
			else:	
				get_tree().change_scene_to_file("res://scenes/guessing_loading.tscn")
		else:
			awarded = true
			if Firebase.current_q_index == Firebase.question_order.size():
				next_button.text = "SHOW SCORES"
			next_button.show()
			


func _on_http_request_not_host_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if not Firebase.data_dict.has("guessed"):
			if Firebase.current_q_index == Firebase.data_dict["users"].keys().size():
				Firebase.current_q_index = 0
				get_tree().change_scene_to_file("res://scenes/scores.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/guessing_loading.tscn")
		else:
			Firebase.get_dictionary(http_not_host)
	else:
		Firebase.get_dictionary(http_not_host)
