"""
Applet: movieslist
Summary: Show A Nearby Movie
Description: Shows a random movie from a nearby theater
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

#use flixter's movie api on rapidapi hub. requires a membership for api key
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
    radiusRaw = config.str("radius", DEFAULT_RADIUS)
    QUERY_STRING_LIST = {"zipCode":zipCodeRaw,"radius":radiusRaw}
    theaterListSize = 0
    theaterListResponse = ""
    theaterName = ""
    theaterDistance = 0
    chosenTheaterNum = 0
    
    #create cache for list of nearby theaters api call
    theaterListCached = cache.get("theater_list")
    if theaterListCached != None:
        theaterListSize = int(theaterListCached.split(",")[0])
        theaterId = theaterListCached.split(",")[1]
        theaterName = theaterListCached.split(",")[2]
        theaterDistance = theaterListCached.split(",")[3]
    else:
        theaterListResponse = http.get(THEATERS_LIST_URL, headers=HEADERS, params=QUERY_STRING_LIST) 
        if theaterListResponse.status_code != 200:
            fail("app failed with status %d", theaterListResponse.status_code)
            BlankGraphic()
        #index json object
        theaterListSize = len(theaterListResponse.json()['data']['theaters'])
        theaterId = theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['id']
        theaterName = theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['name']
        theaterDistance = int(theaterListResponse.json()['data']['theaters'][chosenTheaterNum]['distance'])
        #concat items into string for cache and parse later
        cache.set("theater_list", str(theaterListSize) + "," + str(theaterId) + "," + str(theaterName) + "," + str(theaterDistance), ttl_seconds = 240)
    #choose a random movie theater ID from the list of nearby theaters given radius and zip code
    chosenTheaterNum = random.number(0, theaterListSize - 1)
    print("chosentheaternum: ", chosenTheaterNum)
    QUERY_STRING_DETAIL = {
        "id": theaterId,
    }
    
    #create cache for chosen theater's details api call
    theaterDetailCached = cache.get("theater_detail")
    if theaterDetailCached != None:
        posterUrl = theaterDetailCached.split(",")[0]
        title = theaterDetailCached.split(",")[1]
        motionPictureRating = theaterDetailCached.split(",")[2]
        movieDuration = theaterDetailCached.split(",")[3]
        tomatoRating = theaterDetailCached.split(",")[4]
        ratingImage = theaterDetailCached.split(",")[5]
    else:
        theaterDetailResponse = http.get(THEATERS_DETAIL_URL, headers=HEADERS, params=QUERY_STRING_DETAIL)
        if theaterDetailResponse.status_code != 200:
            fail("app failed with status %d", theaterDetailResponse.status_code)
            BlankGraphic()
        movieListSize = len(theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'])
        #select movie at chosen theater
        chosenMovie = random.number(0, movieListSize - 1)
        print("chosenMovie: ", chosenMovie)
        posterUrl = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['posterImage']['url']
        title = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['name']
        motionPictureRating = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['motionPictureRating']['code']
        movieDuration = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['durationMinutes']
        tomatoRating = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['tomatoRating']['tomatometer']
        ratingImage = theaterDetailResponse.json()['data']['theaterShowtimeGroupings']['movies'][chosenMovie]['tomatoRating']['iconImage']['url']
        cache.set("theater_detail", str(posterUrl) + "," + str(title) + "," + str(motionPictureRating) + "," + str(int(movieDuration)) + "," + str(int(tomatoRating)) + "," + str(ratingImage), ttl_seconds = 240)
      
    return render.Root(
        child = render.Stack(
            children = [
                RenderBottom(font, title, theaterName, theaterDistance),
                animation.Transformation( 
                     duration = 200,
                     delay = 0,
                     keyframes = AnimateKeyframes(),
                     child = RenderTop(font, posterUrl, title, motionPictureRating, movieDuration, tomatoRating, ratingImage),
  
                     ),      
             ]
        ) 
    )

#display blank graphic screen when in failed state
def BlankGraphic():
    print("default graphic function")
    chosenMovie = 0
    posterUrl = QUESTION_MARK_URL
    title = "?"
    motionPictureRating = "?"
    movieDuration = 0
    tomatoRating = 0
    ratingImage = QUESTION_MARK_URL   

#RenderBottom is the bottom layer of elements, top layer slides off the bottom
def RenderBottom(font_in, title_in, theaterNameRow1, theaterDistanceIn):
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
        
#RenderTop is the top layer of elements that will be shown first, then slide off. The poster image will remain after the slide      
def RenderTop(font_in, posterUrl_in, title_in, mprating_in, duration_in, tomatorating_in, ratingimage_in):
    return render.Row(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [

                render.Padding(
                    color = "000",
                    pad = (0, 0, 1, 0),
                    child = render.Image(
                        src = http.get(posterUrl_in).body(),
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

#traverse +40 in x dimension after 55% of frames, and hold to 100% of frames     
def AnimateKeyframes():
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
            
def GetSchema():
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
