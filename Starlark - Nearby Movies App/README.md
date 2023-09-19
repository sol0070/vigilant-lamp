App created by Solly Lin

App written in Starlark - used for pxiel based displays with resolution 32 x 64. Starlark is a 'dialect' of python
This app it part of the Tidbyt pixel displays which are used to show glanceable information such as stocks, transit times, weather, etc. Like the name suggests, this application will be for showing nearby movies. Each app is given a set amount of time & frames to animate based on user configuration. 


# Sample Animations
Oppenheimer
<img src="https://github.com/sol0070/vigilant-lamp/blob/main/Starlark%20-%20Nearby%20Movies%20App/OPPENHEIMER.webp" width=40% height=40%>

Barbie


Ninja Turtles


# About 'Nearby Movies'

First it takes a zipcode and a radius from the user. If not default zipcode and radius will be used. 

The location is used in APIs from Flixter to return a randomly selected theater.
(The Flixter API is from rapid hub and is currently not free, but the key I used will be in the src code)

And the other returns a randomly selected movie from that theater and all details about that movie. 

The JSON response is parsed, and the app shows the poster image on the left and the details of the movie on the right: 
• movie title
• motion picture rating
• duration
• tomatometer percentage rating (and tomato/rotten icon)


An animation will then slide to the right in a sleek manner to keep the poster image in the frame, while revealing info to the left:
• movie title
• Theater name
• Distance to user (mi)

# Coding Features 
• Uses cache standard set by tidbyt community to minimize unnecessary api calls
• 

#TODO
Add show times for the day once API publishes this data

