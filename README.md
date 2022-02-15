# Overwatch League Data Cleanup
SQL (specifically SQLite) code that I used to clean and organize data from the Overwatch League (OWL).

The original source of the raw data can be found here: https://overwatchleague.com/en-us/statslab under "Download the Data" near the bottom.

### Before
![Overwatch League Data raw](https://user-images.githubusercontent.com/97869630/152226888-bdc4aa8b-30c1-4126-bbae-a083f2b9c8ba.PNG)

4,958,301 rows of data from 14 CSV files<br>
Problems included:
- Spelling errors
- Inconsistent formatting
- Incorrect values
- Missing values
- Duplicate rows
- Outdated names
- Lack of overarching organizational structure

### After
![Overwatch League Database organized v3](https://user-images.githubusercontent.com/97869630/153977932-423e1e73-fc6c-4dad-8a03-781adacebc5e.PNG)

4,920,155 rows of data divided over 7 tables:<br>
- 5 tables in a hierarchy `season` > `stage` > `match` > `game` > `round`<br>
- 2 reference tables `player_stat` and `hero`
  
Changes include:
- Fixing all of the aforementioned problems
- Adding **primary keys**
- Adding *foreign keys*
- Adding constraints
- Adding new data via the `hero` table
- Bringing database to first normal form

What I used:
- Window functions
- Aggregate functions
- Troubleshooting queries

## Resources
- Wiki of Overwatch League information <br>    https://liquipedia.net/overwatch/
- VODs of Overwatch League matches (change "match_id" to the match_id number of the match you want to watch) <br>    https://overwatchleague.com/en-us/match/match_id
- Source of raw data (found under "Download the Data" near the bottom) <br>    https://overwatchleague.com/en-us/statslab
