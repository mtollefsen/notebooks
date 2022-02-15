
/*
All phs CSVs have the following columns:

start_time - date and time the match started
match_id - unique identifier for every match
stage - stage of the season
map_type - the map's game mode
map_name - name of the map
player - player name (not the player's real name)
team - team the player is on
stat_name - name of the statistic being measured, many are specific to the hero
hero - hero the player played
stat_amount - measure of the stat_name
*/

  CREATE TABLE player_stat AS
        SELECT * FROM phs_2018_stage_1
     UNION ALL
        SELECT * FROM phs_2018_stage_2
     UNION ALL
        SELECT * FROM phs_2018_stage_3
     UNION ALL
        SELECT * FROM phs_2018_stage_4
     UNION ALL
        SELECT * FROM phs_2018_playoffs
     UNION ALL
        SELECT * FROM phs_2019_stage_1
     UNION ALL
        SELECT * FROM phs_2019_stage_2
     UNION ALL
        SELECT * FROM phs_2019_stage_3
     UNION ALL
        SELECT * FROM phs_2019_stage_4
     UNION ALL
        SELECT * FROM phs_2019_playoffs
     UNION ALL
        SELECT * FROM phs_2020_1
     UNION ALL
        SELECT * FROM phs_2020_2
     UNION ALL
        SELECT * FROM phs_2021_1;


--The three queries ensure the month, day, and hour fields of "start_time" respectively are double digit
        UPDATE player_stat
           SET start_time = "0" || start_time
         WHERE SUBSTR(start_time, 2, 1) = "/";
          
        UPDATE player_stat
           SET start_time = SUBSTR(start_time, 1, 3) || "0" || SUBSTR(start_time, 4)
         WHERE SUBSTR(start_time, 5, 1) = "/";
         
        UPDATE player_stat
           SET start_time = SUBSTR(start_time, 1, 11) || "0" || SUBSTR(start_time, 12)
         WHERE SUBSTR(start_time, 13, 1) = ":";
         
--Converts all values in start_time to "YYYY-MM-DD hh:mm:ss" format
         UPDATE player_stat
            SET start_time = datetime(
                             SUBSTR(start_time, 7, 4) || "-" || SUBSTR(start_time, 1, 2) ||
                             "-" || SUBSTR(start_time, 4, 2) || SUBSTR(start_time, 11) 
	                              )
          WHERE SUBSTRING(start_time, 3, 1) = "/";


        UPDATE player_stat
           SET map_type = SUBSTR(map_type, 1, 1) || LOWER(SUBSTR(map_type, 2));

   ALTER TABLE player_stat
 RENAME COLUMN map_type TO game_mode;
 

--Optional code to add boolean column "title_match"
--which indicates if the match was a title match or not
--NOTE: this only captures title matches for the 2018 and 2019 season
/*
   ALTER TABLE player_stat
    ADD COLUMN title_match AS (CASE
                                 WHEN stage LIKE "%Title Match%"
                                   THEN 1
                                 ELSE 0
                               END);
*/


--Formats the values in stage
        UPDATE player_stat
           SET stage = REPLACE(stage, "Overwatch League Inaugural Season Championship", "2018 Playoffs")
         WHERE SUBSTR(start_time, 1, 4) = "2018";
 
        UPDATE player_stat
           SET stage = REPLACE(stage, "Overwatch League -", "2018")
         WHERE SUBSTR(start_time, 1, 4) = "2018";
         
        UPDATE player_stat
           SET stage = REPLACE(stage, " - Title Matches", "")
         WHERE SUBSTR(start_time, 1, 4) = "2018";
         
        UPDATE player_stat
           SET stage = REPLACE(stage, " Title Matches", "");
         
        UPDATE player_stat
           SET stage = REPLACE(stage, "Overwatch League ", "")
         WHERE SUBSTR(start_time, 1, 4) = "2019";

        UPDATE player_stat
           SET stage = "2019 " || stage
         WHERE SUBSTR(start_time, 1, 4) = "2019" AND
               stage LIKE "%Stage%";
               
        UPDATE player_stat
           SET stage = REPLACE(stage, "OWL ", "");
           
        UPDATE player_stat
           SET stage = REPLACE(stage, "North America", "NA");
           
        UPDATE player_stat
           SET stage = "2020 " || stage
         WHERE SUBSTRING(stage, 1, 1) <> "2";
         
        UPDATE player_stat
           SET stage = stage || " Stage"
         WHERE SUBSTRING(stage, 1, 4) = "2021";
         
	UPDATE player_stat
	   SET stage = "2020 Stage"
	 WHERE stage = "2020 Regular Season";
	 
        UPDATE player_stat
           SET stage = "2019 Playoffs"
         WHERE stage = "2019 Post-Season";
         
	 
        UPDATE player_stat
           SET hero = "Lúcio"
         WHERE hero = "LÃºcio";
         
        UPDATE player_stat
           SET hero = "Torbjörn"
         WHERE hero = "TorbjÃ¶rn";
         
--Alternate queries if you don't want international characters in your dataset
/*
        UPDATE player_stat
           SET hero = "Lucio"
         WHERE hero IN ("LÃºcio", "Lúcio");

        UPDATE player_stat
           SET hero = "Torbjorn"
         WHERE hero IN ("TorbjÃ¶rn", "Torbjörn");
*/

        UPDATE player_stat
           SET hero = "Cassidy"
         WHERE hero = "McCree";


--Optional query if you would like to maintain a table
--of all player stats for All-Star events
/*
  CREATE TABLE player_stat_allstar AS
        SELECT * 
          FROM player_stat
         WHERE stage IN ("2020 APAC All-Stars", "2020 NA All-Stars");
*/

        DELETE 
          FROM player_stat
         WHERE stage IN ("2020 APAC All-Stars", "2020 NA All-Stars");
