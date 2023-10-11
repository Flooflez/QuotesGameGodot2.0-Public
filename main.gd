extends Node

@onready var http_host : HTTPRequest = $"CanvasLayer/User Interface/Host Menu/HTTPRequest(Host)"
@onready var http_connect : HTTPRequest = $"CanvasLayer/User Interface/Connect Menu/HTTPRequest(Connect)"
@onready var http_checker : HTTPRequest = $HTTPRequest
@onready var http_started_checker : HTTPRequest = $"CanvasLayer/User Interface/Connect Menu/HTTPRequest(Started Checker)"

@onready var main_menu = $"CanvasLayer/User Interface/Main Menu"
@onready var connect_menu = $"CanvasLayer/User Interface/Connect Menu"
@onready var host_menu = $"CanvasLayer/User Interface/Host Menu"

@onready var c_notif = $"CanvasLayer/User Interface/Connect Menu/MarginContainer/VboxContainer/Notif"
@onready var c_entry = $"CanvasLayer/User Interface/Connect Menu/MarginContainer/VboxContainer/Name Entry"
@onready var c_button = $"CanvasLayer/User Interface/Connect Menu/MarginContainer/VboxContainer/Connect Button"

@onready var h_notif = $"CanvasLayer/User Interface/Host Menu/MarginContainer/VboxContainer/Notif"
@onready var h_entry =$"CanvasLayer/User Interface/Host Menu/MarginContainer/VboxContainer/Name Entry"
@onready var h_button = $"CanvasLayer/User Interface/Host Menu/MarginContainer/VboxContainer/Host Button"

@onready var h_name_warning = $"CanvasLayer/User Interface/Host Menu/MarginContainer/VboxContainer/NameWarning"
@onready var c_name_warning = $"CanvasLayer/User Interface/Connect Menu/MarginContainer/VboxContainer/NameWarning"

var is_host
var player_name

const BLANK_MESSAGE = "NAME CANNOT BE BLANK"
const NUMBER_MESSAGE = "NAME CANNOT BE A NUMBER"
const REPEAT_MESSAGE = "NAME TAKEN :("
const ANGRY_MESSAGE = "ARE YOU TRYING TO BREAK THE GAME?"

var checking_name = false

func _on_host_menu_button_pressed():
	is_host = true
	main_menu.hide()
	host_menu.show()
	Firebase.check_hosted(http_checker)


func _on_connect_menu_button_pressed():
	is_host = false
	main_menu.hide()
	connect_menu.show()
	
	Firebase.check_started(http_started_checker)


func _on_connect_back_to_main_button_pressed():
	c_notif.hide()
	c_entry.hide()
	c_button.hide()
	c_name_warning.hide()
	connect_menu.hide()
	main_menu.show()


func _on_host_back_to_main_button_pressed():
	h_notif.hide()
	h_entry.hide()
	h_button.hide()
	h_name_warning.hide()
	host_menu.hide()
	main_menu.show()


func _on_host_button_pressed():
	if (h_entry.text == ""):
		h_name_warning.text = BLANK_MESSAGE
		h_name_warning.show()
	elif h_entry.text.is_valid_int():
		h_name_warning.text = NUMBER_MESSAGE
		h_name_warning.show()
	else:
		var isValid = true
		for char in h_entry.text:
			if char in ['.', ',', '$', '#', '[', ']', '/']:
				isValid = false
				break
		if isValid:
			player_name = h_entry.text.to_upper().strip_edges()
			h_button.disabled = true
			Firebase.host_game(http_host)
		else:
			h_name_warning.text = ANGRY_MESSAGE
			h_name_warning.show()


func _on_http_request_request_completed(result, response_code, headers, body): #check if hosted
	if response_code == 200:
		var currently_hosted = body.get_string_from_utf8() == "true" #cast to bool
		if is_host: #trying to host
			if currently_hosted: #can't host
				h_notif.show()
			else:
				h_button.show()
				h_entry.show()
		else: #trying to connect
			if not currently_hosted: #need to host first
				c_notif.show()
			else:
				c_button.show()
				c_entry.show()
	else:
		print("Failed to reach server")


func _on_http_request_host_request_completed(result, response_code, headers, body):
	if response_code == 200:
		Firebase.join_game(http_connect, player_name)


func _on_connect_button_pressed():
	if (c_entry.text == ""):
		c_name_warning.text = BLANK_MESSAGE
		c_name_warning.show()
	elif c_entry.text.is_valid_int():
		c_name_warning.text = NUMBER_MESSAGE
		c_name_warning.show()
	else:
		var isValid = true
		for char in c_entry.text:
			if char in ['.', ',', '$', '#', '[', ']', '/']:
				isValid = false
				break
		if isValid:
			player_name = c_entry.text.to_upper().strip_edges()
			checking_name = true
			Firebase.check_join_game(http_connect,player_name)
			c_button.disabled = true
		else:
			c_name_warning.text = ANGRY_MESSAGE
			c_name_warning.show()


func _on_http_request_connect_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if checking_name:
			if body.get_string_from_utf8() == "null":
				checking_name = false
				Firebase.join_game(http_connect, player_name)
			else:
				c_name_warning.text = REPEAT_MESSAGE
				c_name_warning.show()
				c_button.disabled = false
		else:
			get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	else:
		print(body.get_string_from_utf8())
		print("Error when joining")


func _on_http_request_started_checker_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var currently_started = body.get_string_from_utf8() == "true"
		if currently_started:
			c_name_warning.text = "GAME ALREADY STARTED"
			c_name_warning.show()
		else:
			Firebase.check_hosted(http_checker)
	else:
		print("Error when checking if game started, consider relaunching")
