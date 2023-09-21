App created by Solly Lin

App written in Starlark - used for pxiel based displays with resolution 32 x 64. <br>
Starlark is a 'dialect' of Python. <br>
This app it part of the Tidbyt pixel displays which are used to show glanceable information such as stocks, transit times, weather, etc. Like the name suggests, this application will be for showing nearby movies. Each app is given a set amount of time & frames to animate based on user configuration. 


# Sample Animations

<img src="https://github.com/sol0070/vigilant-lamp/blob/main/Starlark%20-%20Nearby%20Movies%20App/OPPENHEIMER.webp" width=40% height=40%> <br>
Oppenheimer

<img src="https://github.com/sol0070/vigilant-lamp/blob/main/Starlark%20-%20Nearby%20Movies%20App/BARBIE.webp" width=40% height=40%> <br>
Barbie

<img src="https://github.com/sol0070/vigilant-lamp/blob/main/Starlark%20-%20Nearby%20Movies%20App/TURTLES.webp" width=40% height=40%> <br>
Ninja Turtles

<img src="https://github.com/sol0070/vigilant-lamp/blob/main/Starlark%20-%20Nearby%20Movies%20App/BLUE BEETLE.webp" width=40% height=40%> <br>
Blue Beetle


# About 'Nearby Movies'

"Nearby Movies" takes a zipcode and a radius as user input, which are fillable fields when the app is first initialized. If not a default zipcode and radius will be used. 

The location is used in APIs from Flixter to return a randomly selected theater. The API can be found here: https://rapidapi.com/apidojo/api/flixster/ 
(The Flixter API is from rapid hub and is currently not free, but the key I used will be in the src code)

And the other returns a randomly selected movie from that theater and all details about that movie. 

The JSON response is parsed, and the app shows the poster image on the left and the details of the movie on the right: <br>
• movie title <br>
• motion picture rating <br>
• duration <br>
• tomatometer percentage rating (and tomato/rotten icon) <br>


An animation will then slide to the right in a sleek manner to keep the poster image in the frame, while revealing info to the left: <br>
• movie title <br>
• Theater name <br>
• Distance to user (mi) <br>

# Coding Features 
• Uses cache standard set by tidbyt community to minimize unnecessary api calls <br>
• Starlark utilizes widgets library for standard row/column placements

#TODO
Add show times for the day once API publishes this data

