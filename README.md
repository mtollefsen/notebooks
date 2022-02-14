# Overwatch-League-Data-Cleanup
SQL (specifically SQLite) code that I used to clean and organize data from the Overwatch League.

The original source of the raw data can be found here: https://overwatchleague.com/en-us/statslab under "Download the Data" near the bottom.

## Before
![Overwatch League Data raw](https://user-images.githubusercontent.com/97869630/152226888-bdc4aa8b-30c1-4126-bbae-a083f2b9c8ba.PNG)

4,958,301 rows of data from 14 CSV files, problems included:
- Spelling errors
- Inconsistent formatting
- Incorrect values
- Missing values
- Duplicate rows

## After
![Overwatch League Database organized](https://user-images.githubusercontent.com/97869630/152306351-3733b08d-6449-48ed-9d1a-a62543a7ee78.PNG)
- Added primary keys (bolded)
- Added foreign keys
- Added constraints

## What I Used
- Database normalization
- Window functions
- Aggregate functions
- Troubleshooting queries

## Plans for Improvement
- Determine a good primary key for player_stat
- Study more set theory

## Resources
- https://liquipedia.net/overwatch/
- https://overwatchleague.com/en-us/match/match_id (where match_id is the match_id number of the match you want to watch)
