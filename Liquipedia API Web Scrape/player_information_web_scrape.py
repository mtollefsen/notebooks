import requests
from bs4 import BeautifulSoup
import pandas as pd
import sqlite3
import time

# Getting a list of all players from Overwatch_League.db
conn = sqlite3.connect(r'C:\Users\Max\Documents\Data\SQL Database\Overwatch_League.db')
query = "SELECT DISTINCT player FROM player_stat"
player_list = conn.execute(query).fetchall()
player_list = [player[0] for player in player_list]
conn.close()

headers = {'User-Agent': 'SkeleBro',
            'Accept-Encoding': 'gzip'}
masterPlayerData = []
playerID = 0
successfulScrapes = 0
just_length = len(max(player_list, key=len)) + 4

# Gathers player's information from Liquipedia and appends it to masterPlayerData
print('[Starting API Requests]')
for player in player_list:
    playerID += 1
    ambiguous = False
    playerFormatCache = []
    player_data = [playerID, player]
    print(player.ljust(just_length, ' '), end='')
    print(f'({playerID})')

    # Sends requests each with different formatting applied to player name
    for playerNameFormat in [player, player.capitalize(), player.title(), 
                             player.upper(), player.lower()]:
        player = playerNameFormat
        # Prevents repeat requests
        if player in playerFormatCache:
            continue
        else:
            playerFormatCache.append(player)
            
        print(('  ' + player).ljust(just_length, '-'), end='')
        url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
        try:
            response = requests.get(url, headers=headers)
        except:
            print('error with request')
            time.sleep(30)
            continue

        if 'parse' in response.json().keys():
            try:
                presoup = response.json()['parse']['text']['*']
                soup = BeautifulSoup(presoup, 'html5lib')
            except KeyError:
                try:
                    print(response.json()['error']['info'])
                except KeyError:
                    print('failed to parse response')
                finally:
                    time.sleep(30)
                    continue

            # Checking for player info, if none then check for a redirect page
            if soup.select('.infobox-cell-2') == []:
                try:
                    # Checking if there are multiple redirect links
                    if len(response.json()['parse']['links']) > 1:
                        print('Player name has ambiguity!')
                        player_data += (['ambiguous'] * 4)
                        masterPlayerData.append(player_data)
                        ambiguous = True
                        break
                    player = response.json()['parse']['links'][0]['*']    # alternative: player = soup.ul.a['title']
                except (ValueError, KeyError):
                    print('could not find redirect')
                    time.sleep(30)
                    continue
                        
                print('redirect found')
                time.sleep(30)
                url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
                print(('  '+player).ljust(just_length, '-'), end='')
                try:
                    response = requests.get(url, headers=headers)
                except:
                    print('error with redirect request')                      
                    time.sleep(30)
                    continue

                try:
                    presoup = response.json()['parse']['text']['*']
                    soup = BeautifulSoup(presoup, 'html5lib')
                except KeyError:
                    try:
                        print(response.json()['error']['info'])
                    except KeyError:
                        print('failed to parse redirected response')
                    finally:
                        time.sleep(30)
                        continue
                
                if soup.select('.infobox-cell-2') == []:
                    print('redirect doesn\'t have player info')
                    time.sleep(30)
                    continue
                else:
                    break
                
            else:
                break
            
        else:
            try:
                print(response.json()['error']['info'])
            except KeyError:
                print('failed to parse response')
            finally:
                time.sleep(30)
                continue
                
    else:
        print('  Could not find page!')
        player_data += (['could not find page'] * 4)
        masterPlayerData.append(player_data)
        time.sleep(30)
        continue
    
    if ambiguous == True:
        continue
    
    # Creates list of player info from our get request
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
    successfulScrapes += 1
    print('Successful scrape!')
    time.sleep(30)
    continue
print('[Finished with API Requests]')


# Manually add info for players not found by the above API requests
# ['Choihyobin',
#  'Snow',
#  'BEBE',
#  'Mcgravy',
#  'Onlywish',
#  'LeeJaegon',
#  'blase',
#  'Ttuba',
#  'Hybrid']
masterPlayerData[125] = ['Choihyobin', '최효빈', 'Choi Hyo-bin', '1997-09-05', 'South Korea']
masterPlayerData[128] = ['Snow', 'Mikias Yohannes', 'n/a', 'n/a', 'Ethiopia United States']
masterPlayerData[160] = ['BEBE', '윤희창', 'Yoon Hee-chang', '1999-02-03', 'South Korea']
masterPlayerData[181] = ['Mcgravy', 'Caleb McGarvey', 'n/a', '1997-02-11', 'United States']
masterPlayerData[238] = ['Onlywish', '陈李桢', 'Chen Lizhen', '1997-08-15', 'China']
masterPlayerData[265] = ['LeeJaegon', '이재곤', 'Lee Jae-gon', '2001-08-29', 'South Korea']
masterPlayerData[270] = ['blase', 'Jeffrey Tsang', 'n/a', '1999-02-22', 'United States']
masterPlayerData[276] = ['Ttuba', '이호성', 'Lee Ho-sung', '1999-09-21', 'South Korea']
masterPlayerData[332] = ['Hybrid', 'Dominic Grove', 'n/a', '2001-03-28', 'United Kingdom']


# Putting player information into a pandas dataframe
columns = ['player_id', 'pro_name', 'real_name', 'romanized_name', 'birthday', 'country']
df = pd.DataFrame(masterPlayerData, columns=columns)
df.to_sql('player', )


# Exports data frame of player info to SQL database
conn = sqlite3.connect(r'C:\Users\Max\Documents\Data\SQL Database\Overwatch_League.db')
df.to_sql('player', conn, index=False)
conn.close()
