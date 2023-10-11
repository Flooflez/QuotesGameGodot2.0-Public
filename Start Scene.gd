extends Node2D

@onready var http: HTTPRequest = $HTTPRequest
@onready var loading_label = $CanvasLayer/CenterContainer/VBoxContainer/Label
@onready var retry_button = $CanvasLayer/CenterContainer/VBoxContainer/RetryButton

func _ready():
	randomize()
	try_connect()
		

func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200: #sick dawg
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		loading_label.text = "Could not connect to server :("
		retry_button.show()


func _on_retry_button_pressed():
	try_connect()

func try_connect():
	if ReadFile.exists():
		if ReadFile.validate():
			ReadFile.generate_array()
			Firebase.anon_auth(http)
		else:
			loading_label.text = "Please actually add the quotes to the file..."
			retry_button.show()
	else:
		loading_label.text = "Generating empty file, please add the quotes to the file"
		ReadFile.create_empty()
		retry_button.show()
