"""
Applet: movieslist
Summary: Air Now AQI
Description: Displays the current AQI value and level by location using data provided by AirNow.gov.
Author: Solomon Lin
"""
load("encoding/json.star", "json")
load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("cache.star", "cache")
load("random.star", "random")
load("schema.star", "schema")
load("animation.star", "animation")


THEATERS_LIST_URL = "https://flixster.p.rapidapi.com/theaters/list"
DEFAULT_ZIPCODE = "90002"
DEFAULT_RADIUS = "10"

question_mark_url = "https://upload.wikimedia.org/wikipedia/commons/2/25/Icon-round-Question_mark.jpg"

HEADERS = {
	"X-RapidAPI-Key": "895301f7c7mshd0d2bdc3a7fa77dp15526cjsn6646e379a79f",
	"X-RapidAPI-Host": "flixster.p.rapidapi.com"
}

THEATERS_DETAIL_URL = "https://flixster.p.rapidapi.com/theaters/detail"

def main(config):
    font = config.get("font", "tom-thumb")
    zipcode_raw = config.str("zipcode", DEFAULT_ZIPCODE)
    
    radius_raw = config.str("radius", DEFAULT_RADIUS)
    QUERY_STRING_LIST = {"zipCode":zipcode_raw,"radius":radius_raw}
    theater_list_response = http.get(THEATERS_LIST_URL, headers=HEADERS, params=QUERY_STRING_LIST)
    
    theater_list_size = len(theater_list_response.json()['data']['theaters'])
    chosen_theater_num = random.number(0, theater_list_size - 1)
    
    #first movie theater
    theater_id = theater_list_response.json()['data']['theaters'][chosen_theater_num]['id']
    theater_name = theater_list_response.json()['data']['theaters'][chosen_theater_num]['name']
    
    
    QUERY_STRING_DETAIL = {
        "id": theater_id,
    }
    
    theater_detail_response = http.get(THEATERS_DETAIL_URL, headers=HEADERS, params=QUERY_STRING_DETAIL)
    movie_list_size = len(theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'])
    print("movie list size is: " + str(movie_list_size))
    if movie_list_size < 1:
        chosen_movie = 0
        poster_url = question_mark_url
        title = "?"
        motionpicture_rating = "?"
        movie_duration = "?"
        tomatoRating = "?"
        ratingImage = question_mark_url
    else:
        chosen_movie = random.number(0, movie_list_size - 1)
        #select movie at chosen theater
        poster_url = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['posterImage']['url']
        title = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['name']
        motionpicture_rating = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['motionPictureRating']['code']
        movie_duration = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['durationMinutes']
        tomatoRating = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['tomatoRating']['tomatometer']
        ratingImage = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['tomatoRating']['iconImage']['url']
   

    

    return render.Root(
        child = render.Sequence(
            children = [
                animation.Transformation( 
                     duration = 150,
                     delay = 0,
                     keyframes = animate_keyframes(),
                     child = render.Column(
                        expanded = True,
                        main_align = "start",
                        children = [
                            render1(font, poster_url, title, motionpicture_rating, movie_duration, tomatoRating, ratingImage),
                        ]
                     ),
                 ),
             ]
         )
    )
       
def render1(font_in, poster_url_in, title_in, mprating_in, duration_in, tomatorating_in, ratingimage_in):
    return render.Row(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [
                # render.Column(
                    # main_align = "space_between",
                 # children = [
                    # render.Marquee(
                    # width = 40,
                    # child = render.Text(title_in, font = "tb-8"),
                    # ),
                    # render.Box(
                    # width = 38,
                    # height = 1,
                    # color = "#78DECC",
                    # ),
                    # render.Marquee(
                    # width = 40,
                    # child = render.Text("Playing At: ", font = "tb-8"),
                    # ),
                # ],
                 # ),  
                render.Padding(
                    pad = (0, 0, 1, 0),
                    child = render.Image(
                        src = http.get(poster_url_in).body(),
                        width = 24,
                        height = 32,
                        ),          
                ),
                 render.Column(
                 main_align = "space_between",
                 children = [
                    render.Marquee(
                    width = 40,
                    child = render.Text(title_in, font = "tb-8"),
                    ),
                     
                    render.Box(
                    width = 38,
                    height = 1,
                    color = "#78DECC",
                    ),
                    
                    render.Box(
                        width = 40,
                        height = 7,
                        child = render.Text(mprating_in, font = font_in),
                    ),

                    render.Box(
                        width = 40,
                        height = 7,
                        child = render.Text(str(int(duration_in)) + " mins", font = font_in),
                    ),
                    
                    render.Row(
                        expanded = True,
                        main_align = "center",
                        cross_align = "center",
                        children = [
                            render.Box(
                                width = 15,
                                height = 7,
                                child = render.Text(str(int(tomatorating_in)) + "%", font = font_in),
                            ),
                            render.Image(
                                src = http.get(ratingimage_in).body(),
                                width = 7,
                                height = 6,
                            )
                        ]
                    )
                    ] 
                    ),     
            ]
        )
       
def animate_keyframes():
    return [
        animation.Keyframe(
            percentage = 0.0,
            transforms = [animation.Translate(x = -0, y = 0)],
        ),
        animation.Keyframe(
            percentage = 1.0,
            transforms = [animation.Translate(x = 0, y = 0)],
        ),
    ]
       
       
def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "zipcode",
                name = "zipcode",
                desc = "Enter 5 digit zipCode",
                icon = "key",
            ),
            schema.Text(
                id = "radius",
                name = "radius",
                desc = "Enter theater search radius",
                icon = "bus",
            ),
        ],
    )

