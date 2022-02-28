import sqlite3
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

# Getting a list of all players from Overwatch_League.db
conn = sqlite3.connect(r'C:\Users\Max\Documents\Data\SQL Database\Overwatch_League.db')
query = "SELECT DISTINCT player FROM player_stat"
player_list = conn.execute(query).fetchall()
player_list = [player[0] for player in player_list]


headers = {'User-Agent': 'SkeleBro',
            'Accept-Encoding': 'gzip'}

masterPlayerData = []
count = 0
just_length = len(max(player_list, key=len)) + 4

# Gathers player's information from Liquipedia and appends it to masterPlayerData
print('[Starting API Requests]')
for player in player_list:
    count += 1
    print(f'{player} ({count}) ')
    player_data = [player]
    
    # searching player name formats should be step one
    for player_alt in [player, player.capitalize(), player.title(), 
                       player.upper(), player.lower()]:
        player = player_alt
        print(('  ' + player).ljust(just_length, '-'), end='')
        url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
        try:
            response = requests.get(url, headers=headers)
        except:
            print('error with request')
            time.sleep(30)
            continue
        else:
            if 'parse' in response.json().keys():
                break
            else:
                print('\"parse\" key not here')
                time.sleep(30)
    else:
        print('  Could not find \"parse\" key!')
        player_data += (['could not find \"parse\" key'] * 4)
        masterPlayerData.append(player_data)
        time.sleep(30)
        
        
    # Checking if response is a redirect to player's page
    presoup = response.json()['parse']['text']['*']
    soup = BeautifulSoup(presoup, 'html5lib')
    if soup.select('.infobox-cell-2') == []:
        try:
            player = soup.ul.a['title']
        except ValueError:
            player_data += (['could not find redirect'])
            masterPlayerData.append(player_data)
            print('Could not find redirect!')
            time.sleep(30)
            break
        else:
            print('redirect found')
            time.sleep(30)
            url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
            print(('  '+player).ljust(just_length, '-'), end='')
            try:
                response = requests.get(url, headers=headers)
            except:
                print('Error with redirect request!')
                time.sleep(30)
                break
            else:
                presoup = response.json()['parse']['text']['*']
                soup = BeautifulSoup(presoup, 'html5lib')
    
    
    player_info = [i.text for i in list(soup.select('.infobox-cell-2'))]
    # Add real name
    try:
        name_index = player_info.index('Name:') + 1
    except ValueError:
        player_data.append('n/a')
    else:
        player_data.append(player_info[name_index])
       
    # Add romanized name
    try:
        rname_index = player_info.index('Romanized Name:') + 1
    except ValueError:
        player_data.append('n/a')
    else:
        player_data.append(player_info[rname_index])
        
    # Add birthday
    try:
        birth_index = player_info.index('Birth:') + 1
    except ValueError:
        player_data.append('n/a')
    else:
        birthday = player_info[birth_index]
        try:
            temp_index1 = birthday.index('(') + 1
            temp_index2 = birthday.index(')')
        except ValueError:
            print('problem with birthday--', end='')
            player_data.append(player_info[birth_index].lstrip())
        else:
            player_data.append(player_info[birth_index][temp_index1:temp_index2].lstrip())
        
    # Add country
    try:
        country_index = player_info.index('Country:') + 1
    except ValueError:
        player_data.append('n/a')
    else:
        player_data.append(player_info[country_index].strip())
        
    masterPlayerData.append(player_data)
    print('Successful response!')
    time.sleep(30)
    continue

print('[Finished with API Requests]')
