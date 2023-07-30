"""
Applet: AirNowAQI
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


THEATERS_LIST_URL = "https://flixster.p.rapidapi.com/theaters/list"
DEFAULT_ZIPCODE = "90002"
DEFAULT_RADIUS = "10"



HEADERS = {
	"X-RapidAPI-Key": "895301f7c7mshd0d2bdc3a7fa77dp15526cjsn6646e379a79f",
	"X-RapidAPI-Host": "flixster.p.rapidapi.com"
}


posterImageUrl = "https://m.media-amazon.com/images/I/81F5PF9oHhL._AC_SL1500_.jpg"

THEATERS_DETAIL_URL = "https://flixster.p.rapidapi.com/theaters/detail"


def main(config):
    font = config.get("font", "tom-thumb")
    zipcode_raw = config.str("zipcode", DEFAULT_ZIPCODE)
    
    radius_raw = config.str("radius", DEFAULT_RADIUS)
    QUERY_STRING_LIST = {"zipCode":zipcode_raw,"radius":radius_raw}
    theater_list_response = http.get(THEATERS_LIST_URL, headers=HEADERS, params=QUERY_STRING_LIST)
    
    #first movie theater
    theater_id= theater_list_response.json()['data']['theaters'][0]['id']
    theater_name = theater_list_response.json()['data']['theaters'][0]['name']
    
    
    QUERY_STRING_DETAIL = {
        "id": theater_id,
    }
    
    theater_detail_response = http.get(THEATERS_DETAIL_URL, headers=HEADERS, params=QUERY_STRING_DETAIL)
    
    


    poster_url = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][0]['posterImage']['url']
    
    
    title = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][0]['name']
    motionpicture_rating = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][0]['motionPictureRating']['code']
    movie_duration = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][0]['durationMinutes']
    print(movie_duration)
    tomatoRating = theater_detail_response.json()['data']['theaterShowtimeGroupings']['movies'][0]['tomatoRating']['tomatometer']
    

    return render.Root(
        child = render.Row(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [
             render.Image(
                        src = http.get(poster_url).body(),
                        width = 24,
                        height = 32,
                    ),                     
                 render.Column(
                 main_align = "space_between",
                 children = [
                    render.Marquee(
                    width = 40,
                    child = render.Text(title, font = "tb-8"),
                    ),
                     
                    render.Box(
                    width = 40,
                    height = 1,
                    color = "#78DECC",
                    ),
                    
                    render.Marquee(
                        width = 40,
                        child = render.Text(motionpicture_rating, font = font),
                    ),

                    render.Marquee(
                        width = 40,
                        child = render.Text(str(int(movie_duration)) + " mins", font = font),
                    ),
                    
                    render.Marquee(
                        width = 40,
                        child = render.Text(str(int(tomatoRating)) + "%", font = font),
                    ),
                    ]
                         
                    ),
                        
            ]
        
        )
        )
            
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

