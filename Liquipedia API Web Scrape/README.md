# Liquipedia API Web Scrape
Python code that gets information on the players that are in our [Overwatch League dataset](https://github.com/mtollefsen/overwatch-league-data-projects/tree/main/Data%20Cleanup) by sending requests to Liquipedia's API and parsing the HTML.

## (Simplified) Flow Chart
![player_info Flowchart](https://user-images.githubusercontent.com/97869630/156086689-24c7ee98-da6f-4e35-a83e-d993c63836a9.png) <br>
 This is the flow the code making API requests follows. A GET request is sent for every player's name in multiple formats, taking a fake player name "WiNner BIRD" as an example the code would check the following formats of that player's name:
 - Original Format: WiNner BIRD
 - Capital Case: Winner bird
 - Title Case: Winner Bird
 - Upper Case: WINNER BIRD
 - Lower Case: winner bird <br>

Should any of these lead to a player page with information the code scrapes the info and moves on to the next player. All requests are spaced out by 30 seconds per [Liquipedia's API Terms of Use](https://liquipedia.net/api-terms-of-use).


## Source & Copyright
Liquipedia content is licensed under CC-BY-SA 3.0, which requires that you attribute Liquipedia as the source of your data. See [Liquipedia:Copyrights](https://liquipedia.net/commons/Liquipedia:Copyrights) for more information.
