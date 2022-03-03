import requests
from bs4 import BeautifulSoup
import pandas as pd
import sqlite3
import time

def waitThirty():
    for i in range(30, 0, -1):
        count = str(i).ljust(2, ' ')
        print(f'\r{count}', end='\r', flush=True)
        time.sleep(1)
    print('\r', end='')


# Getting a list of all players from Overwatch_League.db
conn = sqlite3.connect(r'URL HERE')
query = "SELECT DISTINCT player FROM player_stat"
playerList = conn.execute(query).fetchall()
playerList = [player[0] for player in playerList]
conn.close()


headers = {'User-Agent': 'USER AGENT HERE',
            'Accept-Encoding': 'gzip'}
masterPlayerData = []
playerID = 0
successfulScrapes = 0
justLength = len(max(playerList, key=len)) + 4
formatAltCount = 0


print('[Starting API Requests]')

# Gathers player's information from Liquipedia and appends it to masterPlayerData
for player in playerList:
    playerID += 1
    ambiguous = False
    playerFormatCache = []
    formatAltNeeded = False
    playerData = [playerID, player]
    print(player.ljust(justLength, ' '), end='')
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
            if len(playerFormatCache) > 1:
                formatAltNeeded = True


        print(('  ' + player).ljust(justLength, '-'), end='')
        url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
        try:
            response = requests.get(url, headers=headers)
        except:
            print('error with request')
            waitThirty()
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
                    waitThirty()
                    continue

            # Checking for player info, if none then check for a redirect page
            if soup.select('.infobox-cell-2') == []:
                try:
                    # Checking if there are multiple redirect links
                    if len(response.json()['parse']['links']) > 1:
                        print('Player name has ambiguity!')
                        playerData += (['ambiguous'] * 4)
                        masterPlayerData.append(playerData)
                        ambiguous = True
                        break
                    player = response.json()['parse']['links'][0]['*']    # alternative: player = soup.ul.a['title']
                except (ValueError, KeyError):
                    print('could not find redirect')
                    waitThirty()
                    continue
                        
                print('redirect found')
                time.sleep(30)
                url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + player
                print(('  '+player).ljust(justLength, '-'), end='')
                try:
                    response = requests.get(url, headers=headers)
                except:
                    print('error with redirect request')                      
                    waitThirty()
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
                        waitThirty()
                        continue
                
                if soup.select('.infobox-cell-2') == []:
                    print('redirect doesn\'t have player info')
                    waitThirty()
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
                waitThirty()
                continue
            
            
    else:
        print('  Could not find page!')
        playerData += (['could not find page'] * 4)
        masterPlayerData.append(playerData)
        waitThirty()
        continue
    
    if ambiguous == True:
        continue
    
    # Creates list of player info from our get request
    playerInfo = [i.text for i in list(soup.select('.infobox-cell-2'))]
    
    # Add real name
    try:
        nameIndex = playerInfo.index('Name:') + 1
    except ValueError:
        playerData.append('n/a')
    else:
        playerData.append(playerInfo[nameIndex])
       
    # Add romanized name
    try:
        rnameIndex = playerInfo.index('Romanized Name:') + 1
    except ValueError:
        playerData.append('n/a')
    else:
        playerData.append(playerInfo[rnameIndex])
        
    # Add birthday
    try:
        birthIndex = playerInfo.index('Birth:') + 1
    except ValueError:
        playerData.append('n/a')
    else:
        birthday = playerInfo[birthIndex]
        try:
            tempIndex1 = birthday.index('(') + 1
            tempIndex2 = birthday.index(')')
        except ValueError:
            playerData.append(playerInfo[birthIndex].lstrip())
        else:
            playerData.append(playerInfo[birthIndex][tempIndex1:tempIndex2].lstrip())
        
    # Add country
    try:
        countryIndex = playerInfo.index('Country:') + 1
    except ValueError:
        playerData.append('n/a')
    else:
        playerData.append(playerInfo[countryIndex].strip())
        
    if formatAltNeeded:
        formatAltCount += 1
    
    masterPlayerData.append(playerData)
    successfulScrapes += 1
    print('Successful scrape!')
    waitThirty()
    continue

print('[Finished with API Requests]')
print()
print(f'{playerID} scrape attempts')
print(f'{successfulScrapes} successful scrapes')
print(f'{formatAltCount} times an alt format was needed')


# Manually add info for players not found by the above API requests
masterPlayerData[125][1:] = ['Choihyobin', '최효빈', 'Choi Hyo-bin', '1997-09-05', 'South Korea']
masterPlayerData[128][1:] = ['Snow', 'Mikias Yohannes', 'n/a', 'n/a', 'Ethiopia United States']
masterPlayerData[160][1:] = ['BEBE', '윤희창', 'Yoon Hee-chang', '1999-02-03', 'South Korea']
masterPlayerData[181][1:] = ['Mcgravy', 'Caleb McGarvey', 'n/a', '1997-02-11', 'United States']
masterPlayerData[238][1:] = ['Onlywish', '陈李桢', 'Chen Lizhen', '1997-08-15', 'China']
masterPlayerData[265][1:] = ['LeeJaegon', '이재곤', 'Lee Jae-gon', '2001-08-29', 'South Korea']
masterPlayerData[270][1:] = ['blase', 'Jeffrey Tsang', 'n/a', '1999-02-22', 'United States']
masterPlayerData[276][1:] = ['Ttuba', '이호성', 'Lee Ho-sung', '1999-09-21', 'South Korea']
masterPlayerData[332][1:] = ['Hybrid', 'Dominic Grove', 'n/a', '2001-03-28', 'United Kingdom']


# Putting player information into a pandas DataFrame
columns = ['player_id', 'pro_name', 'real_name', 'romanized_name', 'birthday', 'country']
df = pd.DataFrame(masterPlayerData, columns=columns)


# Exports DataFrame of player info to SQL database
conn = sqlite3.connect(r'URL HERE')
df.to_sql('player', con=conn, index=False)
conn.close()
