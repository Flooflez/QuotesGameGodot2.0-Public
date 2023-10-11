extends Node2D

@onready var host_container = $"CanvasLayer/Lobby/Host Buttons Container"
@onready var start_button = $"CanvasLayer/Lobby/Host Buttons Container/HBoxContainer/Start Button Container/Start Button"

@onready var http = $HTTPRequest
@onready var http_pusher = $HTTPPusher

@onready var player_count_label = $"CanvasLayer/Lobby/MarginContainer2/VBoxContainer/Player Count"
@onready var player_name_label = $"CanvasLayer/Lobby/MarginContainer2/VBoxContainer/Player Names"

@onready var no_rounds_spinbox = $"CanvasLayer/Lobby/Host Buttons Container/HBoxContainer/Number of Rounds"

const default_rounds = [0,0,4,4,3,3,2,2] #up to 7 configured

var user_array = []
var num_players = 0
var num_rounds = 0


func _ready():
	if Firebase.is_host:
		host_container.show() 
	Firebase.get_dictionary(http)


func _on_http_request_request_completed(result, response_code, headers, body):
	var response = Firebase.json_to_response(body)
	if response_code == 200: #sick dawg
		user_array = response["users"].keys()
		num_players = user_array.size()
		_update_ui()
		if response["game_started"] == true:
			get_tree().change_scene_to_file("res://scenes/writing.tscn")
		else:
			Firebase.get_dictionary(http)
		
	else:
		print("Error getting data")
		if start_button.disabled:
			start_button.disabled = false
		Firebase.get_dictionary(http)
		

func _update_ui():
	var res = ""
	for username in user_array:
		res += username + "\n"
	player_name_label.text = res
	player_count_label.text = "Number of Players: " + str(num_players)
	if num_players > 1:
		start_button.show()
	

func _on_start_button_pressed():
	if no_rounds_spinbox.value == 0:
		if num_players >= 8:
			num_rounds = 1
		else:
			num_rounds = default_rounds[num_players]
	else:
		num_rounds = no_rounds_spinbox.value
	Firebase.start_game(http_pusher, num_rounds)
	start_button.disabled = true
	
