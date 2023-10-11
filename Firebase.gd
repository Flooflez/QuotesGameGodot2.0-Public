extends Node

#Static Object used to make Firebase Calls

const API_KEY := "[INSERT YOUR FIREBASE API KEY]"
#ensure anon auth is enabled in firebase

const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const DATABASE_URL := "[INSERT YOUR FIREBASE REALTIME DATABASE URL]"

var ID_token = "NONE"
var is_host = false

var data_dict = {}

var number_of_rounds = 0
var current_round = 1

var score = 0

var player_fake_quote

var player_name

var question_order = []
var question_order_generated = false
var current_q_index = 0

var was_last_guess_correct = false
var curr_guess
var answer

func json_to_response(body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	return json.get_data()

func anon_auth(http_request: HTTPRequest):
	http_request.request_completed.connect(self._auth_completed)
	var headers = ["Content-Type: application/json"]
	var data = '{"returnSecureToken":true}'
	http_request.request(REGISTER_URL, headers, HTTPClient.METHOD_POST, data)


func _auth_completed(result, response_code, headers, body):
	var response = json_to_response(body)
	if response_code == 200: #sick dawg
		ID_token = response["idToken"]
	else:
		print("Error when authenticating")
		print(response)

func get_dictionary(http_request: HTTPRequest):
	if not http_request.request_completed.is_connected(self._get_dict_completed):
		http_request.request_completed.connect(self._get_dict_completed)
	http_request.request(DATABASE_URL + "/.json?auth=" + ID_token)
	
func _get_dict_completed(result, response_code, headers, body):
	var response = json_to_response(body)
	if response_code == 200: #sick dawg
		data_dict = response
	else:
		print("Error getting data")
		print(response)

func check_hosted(http_request: HTTPRequest):
	http_request.request(DATABASE_URL + "/game_hosted.json?auth=" + ID_token)
	
func check_started(http_request: HTTPRequest):
	http_request.request(DATABASE_URL + "/game_started.json?auth=" + ID_token)
	

func host_game(http_request: HTTPRequest):
	http_request.request_completed.connect(self._host_completed)
	var data = "true"
	http_request.request(DATABASE_URL + "/game_hosted.json?auth=" + ID_token, [], HTTPClient.METHOD_PUT, data)

func _host_completed(result, response_code, headers, body):
	var response = json_to_response(body)
	if response_code == 200: #sick dawg
		is_host = true
	else:
		print("Error hosting game")
		print(response)

func check_join_game(http_request: HTTPRequest, in_player_name):
	http_request.request(DATABASE_URL + "/users/" + in_player_name + ".json?auth=" + ID_token, [], HTTPClient.METHOD_GET, "")
	
func join_game(http_request: HTTPRequest, in_player_name):
	player_name = str(in_player_name)
	var data = JSON.stringify({player_name : {"score" : 0}})
	http_request.request(DATABASE_URL + "/users.json?auth=" + ID_token, [], HTTPClient.METHOD_PATCH, data)

func start_game(http_request: HTTPRequest, no_rounds):
	number_of_rounds = no_rounds
	var data = "true"
	http_request.request(DATABASE_URL + "/game_started.json?auth=" + ID_token, [], HTTPClient.METHOD_PUT, data)


func submit_fake_quote(http_request: HTTPRequest, fake_quote, real_quotes):
	player_fake_quote = str(fake_quote)
	var data = JSON.stringify({player_name : {"fake" : player_fake_quote, "real" : real_quotes}})
	http_request.request(DATABASE_URL + "/submitted.json?auth=" + ID_token, [], HTTPClient.METHOD_PATCH, data)
	
func submit_guess(http_request: HTTPRequest, current_guess, right_answer, my_turn = false):
	var correct_as_int = 0
	if not my_turn:
		was_last_guess_correct = current_guess == right_answer
		if was_last_guess_correct: 
			correct_as_int = 1
	else:
		was_last_guess_correct = false
	curr_guess = current_guess
	answer = right_answer
	var data = JSON.stringify({player_name : correct_as_int})
	http_request.request(DATABASE_URL + "/guessed.json?auth=" + ID_token, [], HTTPClient.METHOD_PATCH, data)
	
func generate_question_order():
	question_order = data_dict["users"].keys()
	question_order.shuffle()
	question_order_generated = true
	current_q_index = 0

func start_guess(http_request: HTTPRequest):
	var data = JSON.stringify(question_order[current_q_index])
	data_dict["current_question_player"] = question_order[current_q_index]
	http_request.request(DATABASE_URL + "/current_question_player.json?auth=" + ID_token, [], HTTPClient.METHOD_PUT, data)

func award_points(http_request: HTTPRequest):
	var current_player = data_dict["current_question_player"]
	var score_dict = data_dict["users"]
	for player_name in data_dict["guessed"]:
		var value = data_dict["guessed"][player_name]
		score_dict[player_name]["score"] += value*100
		if value == 0 and player_name != current_player:
			score_dict[current_player]["score"] += 100
	
	var data = JSON.stringify(score_dict)
	http_request.request(DATABASE_URL + "/users.json?auth=" + ID_token, [], HTTPClient.METHOD_PUT, data)

func clear_guesses(http_request: HTTPRequest):
	http_request.request(DATABASE_URL + "/guessed.json?auth=" + ID_token , [], HTTPClient.METHOD_DELETE, "")

func clear_submissions(http_request: HTTPRequest):
	http_request.request(DATABASE_URL + "/submitted.json?auth=" + ID_token , [], HTTPClient.METHOD_DELETE, "")

func clear_current_player(http_request: HTTPRequest):
	http_request.request(DATABASE_URL + "/current_question_player.json?auth=" + ID_token , [], HTTPClient.METHOD_DELETE, "")



func reset_all(http_request: HTTPRequest):
	var data = JSON.stringify({"game_started" : false, "game_hosted" : false })
	http_request.request(DATABASE_URL + "/.json?auth=" + ID_token, [], HTTPClient.METHOD_PUT, data)
