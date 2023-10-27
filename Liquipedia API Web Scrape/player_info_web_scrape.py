import requests
from bs4 import BeautifulSoup
import pandas as pd
import sqlite3
import time


def waitThirty():
    """
    Prints a 30 second countdown.

    Args:
        None

    Returns:
        None
    """
    for i in range(30, 0, -1):
        count = str(i).ljust(2, ' ')
        print(f'\r{count}', end='\r', flush=True)
        time.sleep(1)
    print('\r', end='')
# end of waitThirty function definition

def getPlayerInfo(headers, player):
    """
    Retrieves pro player's information from their Liquepedia.net page.

    Takes a professional Overwatch League player's name which is used to makes GET requests to 
    Liquipedia.net's API which returns HTML that is then parsed for the player's information using 
    BeautifulSoup. Function will try multiple formats (different capitalization combinations) of the 
    player's name to make requests with.

    Args:
        headers: dict with header information for API requests.
        player: string of player name to make requests for.

    Returns:
        List with the player's information if the given player's Liquepedia.net page was
        succesfully found. If not, a string of what happened is returned instead.
        This string can be:
            "not found" - for when every player name format was tried with no results
            "ambiguous" - for when a redirect page with multiple redirects was reached
    """
    playerFormatCache = []
    for playerNameFormat in [player, 
                             player.capitalize(), 
                             player.title(), 
                             player.upper(), 
                             player.lower()]:

        # check if we've already made a request with this player name format (prevents repeat requests)
        if playerNameFormat in playerFormatCache:
            continue

        # make initial request
        print(('  ' + playerNameFormat).ljust(justLength, '-'), end='')
        url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + playerNameFormat
        try:
            response = requests.get(url, headers=headers)
        except:
            print('error with request')
            waitThirty()
            continue

        # if parse in initial response from request
        if 'parse' in response.json().keys():
            # try to parse initial response
            try:
                presoup = response.json()['parse']['text']['*']
                soup = BeautifulSoup(presoup, 'html5lib')
            except KeyError:
                try:
                    print(response.json()['error']['info'])   # try to print error info from HTML that was scraped
                except KeyError:
                    print('failed to parse response')
                finally:
                    waitThirty()
                    continue

            # if there is no player info
            if soup.select('.infobox-cell-2') == []:
                try:
                    # Check if there are multiple redirect links
                    if len(response.json()['parse']['links']) > 1:
                        return "ambiguous"
                    # only one redirect link, grab the page name
                    else:
                        redirectPage = response.json()['parse']['links'][0]['*']    # alternative line of code: player = soup.ul.a['title']
                except (ValueError, KeyError):
                    print('could not find redirect')
                    waitThirty()
                    continue
                        
                # make request for the page we were redirected to
                print('redirect found')
                waitThirty()
                url = r'https://liquipedia.net/overwatch/api.php?action=parse&format=json&page=' + redirectPage
                print(('  '+redirectPage).ljust(justLength, '-'), end='')
                # check response
                try:
                    response = requests.get(url, headers=headers)
                except:
                    print('error with redirect request')                      
                    waitThirty()
                    continue

                # try to parse redirect page
                try:
                    presoup = response.json()['parse']['text']['*']
                    soup = BeautifulSoup(presoup, 'html5lib')
                except KeyError:
                    try:
                        print(response.json()['error']['info'])   # try to print error info from HTML that was scraped
                    except KeyError:
                        print('failed to parse redirected response')
                    finally:
                        waitThirty()
                        continue
                
                # check if there is player info at the redirect page
                if soup.select('.infobox-cell-2') == []:
                    print('redirect doesn\'t have player info')
                    waitThirty()
                    continue
                # player info found
                else:
                    return [i.text for i in list(soup.select('.infobox-cell-2'))]
                
            # player info found
            else:
                return [i.text for i in list(soup.select('.infobox-cell-2'))]
            
        # parsing initial request failed   
        else:
            try:
                print(response.json()['error']['info'])   # try to print error info from HTML that was scraped
            except KeyError:
                print('failed to parse response')
            finally:
                waitThirty()
                continue   # return to main for loop and try requests for another player's name
            
    # outside for loop,
    # every format of the player's name was tried without finding their webpage     
    return "not found"
# End of getPlayerInfo function definition


# Start of script =======================================================================================================
# Get the list of all pro players in Overwatch_League.db (my personal database)
conn = sqlite3.connect(r'FILE PATH TO DATABASE HERE')
query = "SELECT DISTINCT player FROM player_stat"
playerList = conn.execute(query).fetchall()
playerList = [player[0] for player in playerList]
conn.close()

# set variable values
headers = {'User-Agent': 'USER AGENT NAME HERE',  # header for API calls
            'Accept-Encoding': 'gzip'}
masterPlayerData = []  # list where we'll put all player data into
playerID = 0
successfulScrapes = 0
ambiguousPlayerNames = 0
formatAltCount = 0
justLength = len(max(playerList, key=len)) + 4   # justification length for nice printing

print('[Starting API Requests]')

# Main for loop, gather player's information from Liquipedia.net and append it to masterPlayerData
for player in playerList:
    playerID += 1
    formatAltNeeded = False
    playerData = [playerID, player]
    print(player.ljust(justLength, ' '), end='')
    print(f'({playerID})')

    # call getPlayerInfo
    playerInfo = getPlayerInfo(headers, player)
    
    # check for error strings
    if playerInfo == "not found":
        print('  Could not find page!')
        playerData += (['could not find page'] * 4)
        masterPlayerData.append(playerData)
        waitThirty()
        continue
    elif playerInfo == "ambiguous":
        print('Player name has ambiguity!')
        playerData += (['ambiguous'] * 4)
        masterPlayerData.append(playerData)
        ambiguousPlayerNames += 1
        waitThirty()
        continue

    # Player's page was found successfully, add info to masterPlayerData
    # Add real name
    try:
        nameIndex = playerInfo.index('Name:') + 1
    except ValueError:
        playerData.append('n/a')
    else:
        playerData.append(playerInfo[nameIndex])
       
    # Add Romanized name
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

# All API requests finished ==============================================================================================
# print stats
print('[Finished with API Requests]')
print()
print(f'{playerID} total scrape attempts made')
print(f'{successfulScrapes} successful scrapes')
print(f'{ambiguousPlayerNames} ambiguous player names')

# Manually add info for players not found by the above API requests
# (this was added after running the script once and seeing which players the script was unable to get information for)
masterPlayerData[125][1:] = ['Choihyobin', '최효빈', 'Choi Hyo-bin', '1997-09-05', 'South Korea']
masterPlayerData[128][1:] = ['Snow', 'Mikias Yohannes', 'n/a', 'n/a', 'Ethiopia United States']
masterPlayerData[160][1:] = ['BEBE', '윤희창', 'Yoon Hee-chang', '1999-02-03', 'South Korea']
masterPlayerData[181][1:] = ['Mcgravy', 'Caleb McGarvey', 'n/a', '1997-02-11', 'United States']
masterPlayerData[238][1:] = ['Onlywish', '陈李桢', 'Chen Lizhen', '1997-08-15', 'China']
masterPlayerData[265][1:] = ['LeeJaegon', '이재곤', 'Lee Jae-gon', '2001-08-29', 'South Korea']
masterPlayerData[270][1:] = ['blase', 'Jeffrey Tsang', 'n/a', '1999-02-22', 'United States']
masterPlayerData[276][1:] = ['Ttuba', '이호성', 'Lee Ho-sung', '1999-09-21', 'South Korea']
masterPlayerData[332][1:] = ['Hybrid', 'Dominic Grove', 'n/a', '2001-03-28', 'United Kingdom']

# Place player information into a pandas DataFrame
columns = ['player_id', 'pro_name', 'real_name', 'romanized_name', 'birthday', 'country']
df = pd.DataFrame(masterPlayerData, columns=columns)

# Export DataFrame of player info to SQL database
conn = sqlite3.connect(r'URL HERE')
df.to_sql('player', con=conn, index=False)
conn.close()
