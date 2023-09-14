"""
Applet: movieslist
Summary: Show A Nearby Movie
Description: Chooses from a list of nearby theaters, then displays a movie from that theater
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

QUESTION_MARK_URL = "https://upload.wikimedia.org/wikipedia/commons/2/25/Icon-round-Question_mark.jpg"

HEADERS = {
	"X-RapidAPI-Key": "895301f7c7mshd0d2bdc3a7fa77dp15526cjsn6646e379a79f",
	"X-RapidAPI-Host": "flixster.p.rapidapi.com"
}

THEATERS_DETAIL_URL = "https://flixster.p.rapidapi.com/theaters/detail"

def main(config):
    font = config.get("font", "tom-thumb")
    zipCodeRaw = config.str("zipcode", DEFAULT_ZIPCODE)
    
    radius_raw = config.str("radius", DEFAULT_RADIUS)
    QUERY_STRING_LIST = {"zipCode":zipCodeRaw,"radius":radius_raw}
    theaterListSize = 0
    theaterListResponse = ""
    theater_name = ""
    theater_distance = 0
    chosenTheaterNum = 0
    
    theaterListCached = cache.get("theater_list")
    if theaterListCached != None:
        theaterListSize = int(theaterListCached.split(",")[0])
        theater_id = theaterListCached.split(",")[1]
        theater_name = theaterListCached.split(",")[2]
        theater_distance = theaterListCached.split(",")[3]

    else:
        theaterListResponse = http.get(THEATERS_LIST_URL, headers=HEADERS, params=QUERY_STRING_LIST) 
        if theaterListResponse.status_code != 200:
            fail("app failed with status %d", theaterListResponse.status_code)
        theaterListSize = len(theaterListResponse.json()['data']['theaters'])
        theater_id = theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['id']
        theater_name = theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['name']
        theater_distance = int(theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['distance'])
        cache.set("theater_list", str(theaterListSize) + "," + str(theater_id) + "," + str(theater_name) + "," + str(theater_distance), ttl_seconds = 240)
    
    chosenTheaterNum = random.number(0, theaterListSize - 1)
    QUERY_STRING_DETAIL = {
        "id": theater_id,
    }
    
    theaterDetailCached = cache.get("theater_detail")
    if theaterDetailCached != None:
        print("displaying cached data")
        poster_url = theaterDetailCached.split(",")[0]
        title = theaterDetailCached.split(",")[1]
        motionpicture_rating = theaterDetailCached.split(",")[2]
        movie_duration = theaterDetailCached.split(",")[3]
        tomatoRating = theaterDetailCached.split(",")[4]
        ratingImage = theaterDetailCached.split(",")[5]
    else:
        print("Miss, calling API")
        theaterDetailResponse = http.get(THEATERS_DETAIL_URL, headers=HEADERS, params=QUERY_STRING_DETAIL)
        if theaterDetailResponse.status_code != 200:
            fail("app failed with status %d", theaterDetailResponse.status_code)
            #blank_graphic()
        movieListSize = len(theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'])
        chosen_movie = random.number(0, movieListSize - 1)
        #select movie at chosen theater
        poster_url = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['posterImage']['url']
        title = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['name']
        motionpicture_rating = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['motionPictureRating']['code']
        movie_duration = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['durationMinutes']
        tomatoRating = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['tomatoRating']['tomatometer']
        ratingImage = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosen_movie]['tomatoRating']['iconImage']['url']
        cache.set("theater_detail", str(poster_url) + "," + str(title) + "," + str(motionpicture_rating) + "," + str(int(movie_duration)) + "," + str(int(tomatoRating)) + "," + str(ratingImage), ttl_seconds = 240)
      
    return render.Root(
        child = render.Stack(
            children = [
                render_bottom(font, title, theater_name, theater_distance),
                animation.Transformation( 
                     duration = 200,
                     delay = 0,
                     keyframes = animate_keyframes(),
                     child = render_top(font, poster_url, title, motionpicture_rating, movie_duration, tomatoRating, ratingImage),
  
                     ),
                
             ]
        ) 
    )


def blank_graphic():
    print("default graphic function")
    chosen_movie = 0
    poster_url = QUESTION_MARK_URL
    title = "?"
    motionpicture_rating = "?"
    movie_duration = 0
    tomatoRating = 0
    ratingImage = QUESTION_MARK_URL
    

def render_bottom(font_in, title_in, theaterNameRow1, theaterDistanceIn):
     return render.Column(
         main_align = "space_between",
         #expanded = True,
         children = [
            render.Marquee(
            width = 38,
            height = 7,
            child = render.Text(title_in, font = "tb-8"),
            ),            
            render.Box(
            width = 39,
            height = 1,
            color = "#78DECC",
            ),
            render.WrappedText(
            content= theaterNameRow1,
            width=40,
            linespacing = 0,
            font = "tom-thumb", 
            align = "center",
            ),
            render.Box(
                width = 40,
                height = 7,
                child = render.Text(str(int(theaterDistanceIn)) + " mi", font = font_in),
            ),
        ]
     )
                
       
def render_top(font_in, poster_url_in, title_in, mprating_in, duration_in, tomatorating_in, ratingimage_in):
    return render.Row(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [

                render.Padding(
                    color = "000",
                    pad = (0, 0, 1, 0),
                    child = render.Image(
                        src = http.get(poster_url_in).body(),
                        width = 24,
                        height = 32,
                        ),          
                ),
                 render.Box(
                 width = 40,
                 height = 32,
                 color = "000",
                 child = render.Column(
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
                        child = render.Text(str(duration_in) + " mins", font = font_in),
                    ),  
                    render.Row(
                        expanded = True,
                        main_align = "center",
                        cross_align = "center",
                        children = [
                            render.Box(
                                width = 15,
                                height = 7,
                                child = render.Text(str(tomatorating_in) + "%", font = font_in),
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
                 
                 )
            ]
        )


       
def animate_keyframes():
    return [
        animation.Keyframe(
            percentage = 0.0,
            transforms = [animation.Translate(x = 0, y = 0)],
        ),
        animation.Keyframe(
            percentage = 0.5,
            transforms = [animation.Translate(x = 0, y = 0)],
        ),
        animation.Keyframe(
            percentage = 0.55,
            transforms = [animation.Translate(x = 40, y = 0)],
        ),
        animation.Keyframe(
            percentage = 1.0,
            transforms = [animation.Translate(x = 40, y = 0)],
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
                icon = "key",
            ),
        ],
    )

