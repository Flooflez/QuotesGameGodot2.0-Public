extends Control

@onready var http = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	if Firebase.is_host:
		if not Firebase.question_order_generated:
			Firebase.generate_question_order()
			Firebase.question_order_generated = true
		Firebase.start_guess(http)
	else:
		Firebase.get_dictionary(http)


func _on_http_request_request_completed(result, response_code, headers, body):
	var response = Firebase.json_to_response(body)
	if response_code == 200:
		if Firebase.is_host:
			Firebase.current_q_index += 1
			get_tree().change_scene_to_file("res://scenes/guessing.tscn")
		else:
			if response.has("current_question_player"):
				Firebase.current_q_index += 1
				get_tree().change_scene_to_file("res://scenes/guessing.tscn")
			else:
				Firebase.get_dictionary(http)
	else:
		if Firebase.is_host:
			Firebase.start_guess(http)
		else:
			Firebase.get_dictionary(http)
	
