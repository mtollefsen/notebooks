# Overwatch League Data
Data projects that utilize and build upon Overwatch League data that I cleaned and organized. Languages used: SQL, Python.

### Projects
- [Cleanup - Overwatch League Data](https://github.com/maxtoll/Overwatch-League-Data/tree/main/Cleanup)
- [Analysis - The Assault on Assault](https://nbviewer.org/github/maxtoll/Overwatch-League-Data/blob/main/Analysis%20-%20The%20Assault%20on%20Assault.ipynb)
- [Coming Soon]

## Cleanup - Overwatch League Data Results
### Before
![Overwatch League Data raw](https://user-images.githubusercontent.com/97869630/152226888-bdc4aa8b-30c1-4126-bbae-a083f2b9c8ba.PNG)

#### 4,958,301 rows of data from 14 CSV files<br>
#### Problems included
- Spelling errors
- Inconsistent formatting
- Incorrect values
- Missing values
- Duplicate rows
- Outdated names
- Lack of overarching organizational structure

### After
![Overwatch League Database organized v4](https://user-images.githubusercontent.com/97869630/154815413-24f2b310-a25f-4fd7-beed-77aee0237a48.PNG)

#### 4,920,155 rows of data divided over 7 tables<br>
- 5 tables in a hierarchy `season` > `stage` > `match` > `game` > `round`<br>
- 2 reference tables `player_stat` and `hero`
  
#### Changes include
- Fixing all of the aforementioned problems
- Adding **primary keys**
- Adding *foreign keys*
- Adding constraints
- Adding new data via the `hero` table
- Bringing database to first normal form
- Creating database schema

## Resources
- Wiki of Overwatch League information <br>    https://liquipedia.net/overwatch/
- VODs of Overwatch League matches (change "match_id" to the match_id number of the match you want to watch) <br>    https://overwatchleague.com/en-us/match/match_id
- Source of raw data (found under "Download the Data" near the bottom) <br>    https://overwatchleague.com/en-us/statslab
