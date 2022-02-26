'''
This project is a work in progress
'''

import sqlite3
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

# Getting a list of all players from Overwatch_League.db
conn = sqlite3.connect(r'[URL TO  DATABASE]')
query = "SELECT DISTINCT player FROM player_stat"
player_list = conn.execute(query).fetchall()
player_list = [player[0] for player in player_list]

headers = {'User-Agent': '[USER AGENT NAME]',
            'Accept-Encoding': 'gzip'}
data = []
fill_char = '~'
alt_char = '-'
just_length = len(max(player_list, key=len)) + 1



# Adds all player data into a list "data" for conversion into a pandas DataFrame
print('Starting API Requests')
for player in player_list:
    fill_char, alt_char = alt_char, fill_char
    url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
    player_data = [player]
    print(player.ljust(just_length, fill_char), end='')
 
    try:
        response = requests.get(url, headers=headers)
    except:
        player_data += (['request error'] * 4)
        data.append(player_data)
        print('Failed response')
        time.sleep(30)
        continue


    if  response.status_code == 200:
        if 'parse' not in response.json().keys():
            player_data += (['no parse key'] * 4)
            data.append(player_data)
            print('No \"parse\" key')
            time.sleep(30)
            continue
        
        presoup = response.json()['parse']['text']['*']
        soup = BeautifulSoup(presoup, 'html5lib')
        player_attr = [i.text for i in list(soup.select('.infobox-cell-2'))]
        
        # add name
        try:
            name_index = player_attr.index('Name:') + 1
        except ValueError:
            player_data.append('n/a')
        else:
            player_data.append(player_attr[name_index])
           
        # add romanized name
        try:
            rname_index = player_attr.index('Romanized Name:') + 1
        except ValueError:
            player_data.append('n/a')
        else:
            player_data.append(player_attr[rname_index])
            
        # add birthday
        try:
            birth_index = player_attr.index('Birth:') + 1
        except ValueError:
            player_data.append('n/a')
        else:
            birthday = player_attr[birth_index]
            try:
                temp_index = birthday.index('(') - 1
            except ValueError:
                print('Problem with birthday' + (fill_char * 2), end='')
                player_data.append(player_attr[birth_index])
            else:
                player_data.append(player_attr[birth_index][0:temp_index])
            
        # add country
        try:
            country_index = player_attr.index('Country:') + 1
        except ValueError:
            player_data.append('n/a')
        else:
            player_data.append(player_attr[country_index])
        
    else:
        player_data += ([response.status_code] * 4)

    data.append(player_data)
    print('Successful response')
    time.sleep(30)
    continue
print('Finished with API Requests')
