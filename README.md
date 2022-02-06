# Overwatch-League-Data-Cleanup
Repository of code I used to clean and organize data from the Overwatch League using SQL (specifically SQLite).

The original source of the raw data can be found here: https://overwatchleague.com/en-us/statslab

## Before
![Overwatch League Data raw](https://user-images.githubusercontent.com/97869630/152226888-bdc4aa8b-30c1-4126-bbae-a083f2b9c8ba.PNG)
- 14 CSV files
- Spelling errors and inconsistent formatting
- Missing values
- Duplicate rows

## After
![Overwatch League Database organized](https://user-images.githubusercontent.com/97869630/152306351-3733b08d-6449-48ed-9d1a-a62543a7ee78.PNG)

## Takeaways
- I improved my cleaning skills, a few expressions that helped with determining problems in the dataset include: 
  -  IS / IS NOT NULL
  -  DISTINCT
  -  COUNT(column) <> COUNT(DISTINCT(column))
