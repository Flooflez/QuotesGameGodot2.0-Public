extends Control

@onready var http = $HTTPRequest
@onready var http_checker = $HTTPRequestChecker

@onready var next_button = $CanvasLayer/MarginContainer/MarginContainer/NextButton
@onready var leader_board_container = $CanvasLayer/MarginContainer/VBoxContainer/MarginContainer2/LeaderboardContainer
@onready var main_menu_button = $CanvasLayer/MarginContainer/MarginContainer/MainMenuButton

@onready var waiting_label = $CanvasLayer/MarginContainer/MarginContainer2/WaitingLabel

var leaderboard_label
var yellow_leaderboard_label

var ending_game
var loaded_lb = false

# Called when the node enters the scene tree for the first time.
func _ready():
	leaderboard_label = preload("res://instances/leaderboard_label.tscn")
	yellow_leaderboard_label = preload("res://instances/leaderboard_label_yellow.tscn")
	if Firebase.is_host:
		Firebase.question_order_generated = false
		Firebase.current_round += 1
		if Firebase.current_round > Firebase.number_of_rounds:
			main_menu_button.show()
		else:
			next_button.show()
	else:
		waiting_label.show()
	Firebase.get_dictionary(http_checker)


func _on_http_request_checker_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if Firebase.data_dict["game_started"] == false:
			main_menu_button.show()
		elif not Firebase.data_dict.has("submitted"):
			get_tree().change_scene_to_file("res://scenes/writing.tscn")
		else:
			if not loaded_lb:
				_update_ui()
				loaded_lb = true
			if not Firebase.is_host:
				Firebase.get_dictionary(http_checker)
	else:
		Firebase.get_dictionary(http_checker)


func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if not ending_game:
			get_tree().change_scene_to_file("res://scenes/writing.tscn")
		else:
			Firebase.is_host = false
			Firebase.current_q_index = 0
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		if ending_game:
			Firebase.reset_all(http)
		else:
			Firebase.clear_submissions(http)

func _update_ui():
	var scores_array = extract_scores(Firebase.data_dict["users"])
	var names_array = Firebase.data_dict["users"].keys()
	sort_leaderboard(scores_array, names_array)
	for i in range(scores_array.size()):
		var label_control
		if names_array[i] == Firebase.player_name:
			label_control = yellow_leaderboard_label.instantiate()
		else:
			label_control = leaderboard_label.instantiate()
		var label = label_control.get_node("Leaderboard")
		label.text = names_array[i] + ": " + str(scores_array[i])
		label.get_parent().remove_child(label)
		leader_board_container.add_child(label)

func sort_leaderboard(scores, usernames):
	var length = scores.size()
	var swapped = true
	
	while swapped:
		swapped = false
		for i in range(length - 1):
			if scores[i] < scores[i + 1]:
				var temp_score = scores[i]
				scores[i] = scores[i + 1]
				scores[i + 1] = temp_score
				var temp_username = usernames[i]
				usernames[i] = usernames[i + 1]
				usernames[i + 1] = temp_username
				
				swapped = true

func extract_scores(dictionary):
	var scores = []
	for username in dictionary.keys():
		scores.append(dictionary[username]["score"])
	return scores

func _on_next_button_pressed():
	Firebase.clear_submissions(http)
	next_button.disabled = true

func _on_main_menu_button_pressed():
	if Firebase.is_host:
		ending_game = true
		Firebase.reset_all(http)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
