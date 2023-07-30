"""
Applet: americanflag
Summary: USA Flag
Description: Static image of the American Flag.
Author: Solly Lin
"""

load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("cache.star", "cache")
load("encoding/json.star", "json")

WHITE_DOT = render.Circle(color="#fff", diameter=1)

SIX_STARS_ROW = render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children=[WHITE_DOT, WHITE_DOT, WHITE_DOT, WHITE_DOT, WHITE_DOT, WHITE_DOT]
                    )
                    
FIVE_STARS_ROW = render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children=[WHITE_DOT, WHITE_DOT, WHITE_DOT, WHITE_DOT, WHITE_DOT]
                    )

def main():
	return render.Root(
        render.Stack(      
        children = [      
            render.Column(
                children = [
                    render.Box(height = 3, width = 64, color = "#f00"),
                    render.Box(height = 2, width = 64, color = "#fff"),
                    render.Box(height = 2, width = 64, color = "#f00"),
                    render.Box(height = 3, width = 64, color = "#fff"),
                    render.Box(height = 2, width = 64, color = "#f00"),
                    render.Box(height = 3, width = 64, color = "#fff"),
                    render.Box(height = 2, width = 64, color = "#f00"),
                    render.Box(height = 3, width = 64, color = "#fff"),
                    render.Box(height = 2, width = 64, color = "#f00"),
                    render.Box(height = 3, width = 64, color = "#fff"),
                    render.Box(height = 2, width = 64, color = "#f00"),
                    render.Box(height = 2, width = 64, color = "#fff"),
                    render.Box(height = 3, width = 64, color = "#f00"),
                ]
            
            ),           
            render.Box(
                height=17, 
                width=25, 
                color="#119",
                child = render.Column(
                expanded = True,
                main_align = "space_between",
                
                children = [
                    SIX_STARS_ROW, FIVE_STARS_ROW, SIX_STARS_ROW, FIVE_STARS_ROW, SIX_STARS_ROW, FIVE_STARS_ROW, SIX_STARS_ROW, FIVE_STARS_ROW, SIX_STARS_ROW,
                ]
            )     
            ),       
            ]
       )
    )
