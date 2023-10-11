# The Quote Game
 A Jackbox Style Game in Godot using Firebase

## How to play
Welcome to The Quote Game! The hilarious party game where players take on the role of quote-masters, trying to trick your friends into thinking your made-up quotes are totally real!</br>
In this game, players will be presented with real quotes from U.S. presidents, famous celebrities, or even your own friends, along with fake quotes created by their opponents. The goal is to convince their friends that their fake quote is the real deal.</br>
Players, get ready to test your creativity and wit as you come up with the most believable, yet ridiculous quotes you can think of. As the quotes appear on the screen, it's up to you and your friends to vote for the quote you believe is real. Rack up points for successfully tricking your friends and for identifying the real quotes hidden among the fakes.</br>
Will your poker face hold up, or will your friends see through your cunning deception? It's time to find out!</br></br>
The Quote Game is a party game made for any (reasonable) number of players, and can be played with any set of quotes!

## Setup
You will need a Firebase Realtime Database that has a Web App API Key and Anonymous Authentication enabled.</br>
Create a quotes.txt file with each quote on its own line. Please add this quotes file to the Godot folder in the path ``%APPDATA%\Godot\app_userdata\QuotesGameGodot2.0`` or whatever corresponding directory your platform has (you can check out [here](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#accessing-files-in-the-project-folder-res)).

# DISCLAIMERS
## This is not a commericial game in any capacity
This is a game I made for friends, it's just up here if anyone needs reference for Godot 4 connecting to Firebase with the REST API (via the HTTPRequests Class).</br>
I will likely not update this project, nor respond to any (minor) issues submitted. Please do open an issue if you find a security flaw in the program. 

## The code is bad
There are many "hacky" ways of doing things in this project. I highly recommend NOT following what I have done here for any commercial product.</br>
This is largely an experiment for me to learn Godot and try out the Firebase REST API. 

## Fonts
There are 3 fonts used in this project. Please note that Cozy Caps and Skull Bones are **NOT FREE** for commercial use.</br>
For this reason, please do not copy and distribute this project commericially in any capacity.
- [Cozy Caps](https://www.dafont.com/cozy-caps.font) by Stacy Wilson 
- [Skull Bones](https://www.dafont.com/skull-bones.font) by Ramli Setiadi
- [Spicy Soup](https://www.dafont.com/spicy-soup.font) by Khurasan

## Firebase Pricing
Please be aware that while Firebase is a free service, going over the free limits could result in unwanted costs/charges.</br>
It is highly unlikely that you will hit this limit during normal gameplay, but it is totally possible and you should be aware of it.</br>
I am not responsible for any accidental transactions made when running this game. 
