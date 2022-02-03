import pandas as pd
import sqlite3

#   Imports OWL 2018 matches from SQL
database = r'C:\Users\Max\Google Drive\Data\SQL Database\Scrying Pool.db'
conn = sqlite3.connect(database)

OWL_2018 = pd.read_sql('select * from OWL_2018_Raw', con=conn)
conn.close()

#   Converts the list of columns to categorical data
for col in ['map_type', 'map_name', 'team', 'hero', 'player', 'stat_name', 'match_id']:
    OWL_2018[col] = OWL_2018[col].astype('category')

#   Creates a series for stat_name where it is the category dtype
stat_name_cat = OWL_2018.stat_name.astype('category')

#   Creates and inserts the title_match boolean column, indicates if the match is a title match or not
titleMatchBoolean = OWL_2018.stage.str.contains('Title Matches')
OWL_2018.insert(3, 'title_match', titleMatchBoolean)

#   Removes unnecessary portions of the string in stage and adds the year the match took place
OWL_2018.stage = OWL_2018.stage.str.replace('Overwatch League -', '2018')
OWL_2018.stage = OWL_2018.stage.str.replace('Overwatch League Inaugural Season Championship', '2018 Playoffs')
OWL_2018.stage = OWL_2018.stage.str.replace(' Title Matches', '')
OWL_2018.stage = OWL_2018.stage.str.replace(' -', '')

#   Converts stage to category data type
OWL_2018.stage = OWL_2018.stage.astype('category')

#   Replaces all slashes / with a dash -
OWL_2018.start_time = OWL_2018.start_time.str.replace('/', '-')

#   Function corrects date formatting
def formatFix(date: str) -> str:
    #   makes sure all hours are double digit
    if date[-5] == ' ':
        date = date[:-4] + '0' + date[-4:]
       
    #   makes sure all months are double digit
    if date[0] == '1' and date[1] == '-':
        date = '0' + date
        
    #   removes the century from the year
    if date[-10:-8] == '20':
        date = date[:-10] + date[-8:]

    return date

#   Applies the above function to all dates
OWL_2018.start_time = OWL_2018.start_time.apply(formatFix)

#   Converts column to datetime
OWL_2018.start_time = pd.to_datetime(OWL_2018.start_time, format='%m-%d-%y %H:%M')

#   Applies capitalize case to map_type, rename_categories maintains category dtype of column
OWL_2018.map_type = OWL_2018.map_type.cat.rename_categories(str.capitalize)

#   Converts stat_amount to float dtype
OWL_2018.stat_amount = OWL_2018.stat_amount.astype(float)

#   Uploads the current dataset to my SQL database,
#   commented out as I've already uploaded a copy to my SQL database
#conn = sqlite3.connect(database)
#OWL_2018.to_sql(name="OWL_2018", con=conn)
#conn.close()
