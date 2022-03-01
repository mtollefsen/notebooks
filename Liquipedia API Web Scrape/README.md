# Liquipedia API Web Scrape
Python code that gets information on the players that are in our [Overwatch League dataset](https://github.com/mtollefsen/overwatch-league-data-projects/tree/main/Data%20Cleanup) by sending requests to Liquipedia's API and parsing the HTML.

## (Simplified) Flow Chart
![player_info Flowchart](https://user-images.githubusercontent.com/97869630/156086689-24c7ee98-da6f-4e35-a83e-d993c63836a9.png) <br>

This flow chart maps the part of the code that makes API requests. A GET request is sent for every player's name, looking for a page the matches their name. Because pages are case sensitive the code will try multiple formats of a player's name until a page is found or they've run out of formats to try. For example, if the code were trying to find the Liquipedia page for a player that goes by "WiNner BIRD", it would try the following pages in order:
 
 |    Format    |    Result   |
 |--------------|-------------|
 | Original     | WiNner BIRD |
 | Capital case | Winner bird |
 | Title case   | Winner Bird |
 | Upper case   | WINNER BIRD |
 | Lower case   | winner bird |
<br>

All requests are spaced out by 30 seconds per [Liquipedia's API Terms of Use](https://liquipedia.net/api-terms-of-use).


## Source & Copyright
Liquipedia content is licensed under CC-BY-SA 3.0, which requires that you attribute Liquipedia as the source of your data. See [Liquipedia:Copyrights](https://liquipedia.net/commons/Liquipedia:Copyrights) for more information.
