        
	CREATE TABLE round (
                     round_start_time TEXT,
                     round_end_time TEXT,
	             game_id TEXT,
	             round_id TEXT PRIMARY KEY,
	             map_subsection TEXT,
	             attacker TEXT,
	             defender TEXT,
	             attacker_round_end_score INTEGER,
	             defender_round_end_score INTEGER,
	             attacker_time_banked NUMERIC,
	             defender_time_banked NUMERIC,
	             attacker_payload_distance NUMERIC,
	             defender_payload_distance NUMERIC,
	             attacker_control_percent INTEGER,
	             defender_control_percent INTEGER
	             );
	
	 INSERT INTO round
              SELECT round_start_time,
                     round_end_time,
	             match_id || "." || game_number as game_id,
	             match_id || "." || game_number || "." || round_number as round_id,
	             map_subsection,
	             attacker,
	             defender,
	             attacker_round_end_score,
	             defender_round_end_score,
	             attacker_time_banked,
	             defender_time_banked,
	             attacker_payload_distance,
	             defender_payload_distance,
	             attacker_control_percent,
	             defender_control_percent
                FROM match_map_stats;
	
	
	CREATE TABLE game (
                     start_time TEXT,
	  	     match_id TEXT,
		     game_id TEXT PRIMARY KEY,
	             game_number INTEGER,
          	     winner TEXT,
		     loser TEXT,
	             map_name TEXT,
		     game_mode TEXT,
		     winning_score INTEGER,
	             losing_score INTEGER
	             );


         INSERT INTO game
              SELECT DISTINCT 
                     mms.round_start_time as start_time,
	             mms.match_id,
                     mms.match_id || "." || mms.game_number as game_id,
	             mms.game_number,
	             mms.map_winner as winner,
	             mms.map_loser as loser,
	             mms.map_name,
	             ps.game_mode,
	             mms.winning_team_final_map_score as winning_score,
	             mms.losing_team_final_map_score as losing_score	   
                FROM match_map_stats mms
           LEFT JOIN player_stat ps
                  ON mms.match_id = ps.match_id AND
                     mms.map_name = ps.map_name
               WHERE round_number = 1;
	      
	       
	CREATE TABLE match (
                     start_time TEXT,
	             stage TEXT,
		     match_id TEXT PRIMARY KEY,
		     winner TEXT,
	             loser TEXT,
		     winning_score INTEGER,
		     ties INTEGER,
		     losing_score INTEGER
		     );

         INSERT INTO match
              SELECT mms.round_start_time as start_time,
                     mms.stage,
                     g.match_id,
	             mms.match_winner as winner,
	             mms.match_loser as loser,
                     SUM(CASE
	                   WHEN g.winner = mms.match_winner
			     THEN 1
			   ELSE 0
		         END) as winning_score,
	             SUM(CASE
	                   WHEN g.winner = "draw"
			     THEN 1
			   ELSE 0
		         END) as ties,
	             SUM(CASE
	                   WHEN g.winner = mms.match_loser
			     THEN 1
			   ELSE 0
		         END) as losing_score
                FROM game g
                JOIN match_map_stats mms
                  ON g.match_id = mms.match_id AND
                     g.game_number = mms.game_number
               WHERE mms.round_number = 1
            GROUP BY g.match_id;


        CREATE TABLE stage (
                     season TEXT,
	             stage TEXT PRIMARY KEY
	             );

         INSERT INTO stage	 
              SELECT DISTINCT
                     SUBSTRING(stage, 1, 4) as season,
                     stage
                FROM match;


        CREATE TABLE season (
                     season TEXT PRIMARY KEY,
	             winner TEXT
	             );
			 
         INSERT INTO season (season, winner)
              VALUES
                     (2018, "London Spitfire"),
	             (2019, "San Francisco Shock"),
	             (2020, "San Francisco Shock"),
	             (2021, "Shanghai Dragons");


                WITH
     game_id_conv AS (
              SELECT match_id,
	             match_id || "." || game_number as game_id,
	             map_name
                FROM match_map_stats
            GROUP BY match_id, game_number
                     )
		     
              UPDATE player_stat
                 SET match_id = gic.game_id
                FROM game_id_conv gic
               WHERE player_stat.match_id = gic.match_id AND
                     player_stat.map_name = gic.map_name;
      
              UPDATE player_stat
                 SET match_id = "30173.2"
               WHERE start_time = "2019-08-31 03:37:00";
      
         ALTER TABLE player_stat
              RENAME match_id TO game_id;
	      
	       ALTER TABLE player_stat
                DROP COLUMN stage;

         ALTER TABLE player_stat
                DROP COLUMN game_mode;

         ALTER TABLE player_stat
                DROP COLUMN map_name;
		
        CREATE TABLE player_stat_2018 AS 
              SELECT game_id,
                     team,
	             player,
	             hero,
	             stat_name,
                     stat_amount
                FROM player_stat
               WHERE SUBSTR(start_time, 1, 4) = "2018";

        CREATE TABLE player_stat_2019 AS 
              SELECT game_id,
                     team,
	             player,
	             hero,
	             stat_name,
	             stat_amount
                FROM player_stat
               WHERE SUBSTR(start_time, 1, 4) = "2019";

        CREATE TABLE player_stat_2020 AS 
              SELECT game_id,
                     team,
	             player,
	             hero,
	             stat_name,
 	             stat_amount
                FROM player_stat
               WHERE SUBSTR(start_time, 1, 4) = "2020";

        CREATE TABLE player_stat_2021 AS 
              SELECT game_id,
                     team,
	             player,
	             hero,
	             stat_name,
 	             stat_amount
                FROM player_stat
               WHERE SUBSTR(start_time, 1, 4) = "2021";
	       
	       
	CREATE TABLE hero (
                     number,
	             name PRIMARY KEY,
	             role
	             );
