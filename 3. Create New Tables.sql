        
--"round"	
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
	
--"game"	
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
	      
--"match"
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

--"stage"
        CREATE TABLE stage (
                     season TEXT,
	             name TEXT PRIMARY KEY
	             );

         INSERT INTO stage	 
              SELECT DISTINCT
                     SUBSTRING(stage, 1, 4) as season,
                     stage
                FROM match;

--"season"
        CREATE TABLE season (
                     name TEXT PRIMARY KEY,
	             winner TEXT
	             );
			 
         INSERT INTO season (season, winner)
              VALUES (2018, "London Spitfire"),
	             (2019, "San Francisco Shock"),
	             (2020, "San Francisco Shock"),
	             (2021, "Shanghai Dragons");

--"player_stat"
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
		
         ALTER TABLE player_stat
	        DROP COLUMN start_time;

        CREATE TABLE player_stat_new (
                     game_id TEXT NOT NULL,
                     team TEXT NOT NULL,
	             player TEXT NOT NULL,
	             hero TEXT NOT NULL,
	             stat_name TEXT NOT NULL,
                     stat_amount NUMERIC,
		     PRIMARY KEY (game_id, team, player, hero, stat_name)
		     );
	    
	 INSERT INTO player_stat_new
	      SELECT game_id,
		     team,
		     player,
		     hero,
		     stat_name,
		     MIN(stat_amount)
		FROM player_stat
	    GROUP BY game_id, team, player, hero, stat_name;  --group by is used to eliminate the duplicate rows
	                                                      --for Winston - Melee Kills and Mei - Self Healing

          DROP TABLE player_stat;
	 ALTER TABLE player_stat_new RENAME TO player_stat;

--"hero"	       
	CREATE TABLE hero (
                     number INTEGER UNIQUE,
	             name PRIMARY KEY,
	             role TEXT
	             );

         INSERT INTO hero (number, name, role)
              VALUES (1,  "Tracer",        "Damage"),
	             (2,  "Reaper",        "Damage"),
	             (3,  "Widowmaker",    "Damage"),
		     (4,  "Pharah",        "Damage"),
		     (5,  "Reinhardt",     "Tank"),
		     (6,  "Mercy",         "Support"),
		     (7,  "Torbjörn",      "Damage"),
		     (8,  "Hanzo",         "Damage"),
		     (9,  "Winston",       "Tank"),
		     (10, "Zenyatta",      "Support"),
		     (11, "Bastion",       "Damage"),
		     (12, "Symmetra",      "Damage"),
		     (13, "Zarya",         "Tank"),
		     (14, "Cassidy",       "Damage"),
		     (15, "Soldier: 76",   "Damage"),
		     (16, "Lúcio",         "Support"),
		     (17, "Roadhog",       "Tank"),
	             (18, "Junkrat",       "Damage"),
		     (19, "D.Va",          "Tank"),
		     (20, "Mei",           "Damage"),
		     (21, "Genji",         "Damage"),
		     (22, "Ana",           "Support"),
		     (23, "Sombra",        "Damage"),
		     (24, "Orisa",         "Tank"),
		     (25, "Doomfist",      "Damage"),
		     (26, "Moira",         "Support"),
		     (27, "Brigitte",      "Support"),
		     (28, "Wrecking Ball", "Tank"),
		     (29, "Ashe",          "Damage"),
		     (30, "Baptiste",      "Support"),
		     (31, "Sigma",         "Tank"),
		     (32, "Echo",          "Damage"),
		     (33, "Sojourn",       "Damage");

--Adds foreign keys
                     COMMIT;  --prevents SQLite from thinking mutliple transactions are occuring

              PRAGMA foreign_keys = OFF;

               BEGIN TRANSACTION;

	CREATE TABLE round_new (
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
	             defender_control_percent INTEGER,
		     FOREIGN KEY (game_id) REFERENCES game(game_id)
	             );
				 
         INSERT INTO round_new SELECT * FROM round;
          DROP TABLE round;
         ALTER TABLE round_new RENAME TO round;

	CREATE TABLE game_new (
                     start_time TEXT,
	  	     match_id TEXT,
		     game_id TEXT PRIMARY KEY,
	             game_number INTEGER,
          	     winner TEXT,
		     loser TEXT,
	             map_name TEXT,
		     game_mode TEXT,
		     winning_score INTEGER,
	             losing_score INTEGER,
		     FOREIGN KEY (match_id) REFERENCES match(match_id)
	             );
				 
         INSERT INTO game_new SELECT * FROM game;
          DROP TABLE game;
         ALTER TABLE game_new RENAME TO game;
	 
	CREATE TABLE match_new (
                     start_time TEXT,
	             stage TEXT,
		     match_id TEXT PRIMARY KEY,
		     winner TEXT,
	             loser TEXT,
		     winning_score INTEGER,
		     ties INTEGER,
		     losing_score INTEGER,
		     FOREIGN KEY (stage) REFERENCES stage(name)
		     );
			  
	 INSERT INTO match_new SELECT * FROM match;
          DROP TABLE match;
         ALTER TABLE match_new RENAME TO match;

        CREATE TABLE stage_new (
                     season TEXT,
	             name TEXT PRIMARY KEY,
	             FOREIGN KEY (season) REFERENCES season(name)
	             );
				 
	 INSERT INTO stage_new SELECT * FROM stage;
          DROP TABLE stage;
         ALTER TABLE stage_new RENAME TO stage;	

        CREATE TABLE player_stat_new (
                     game_id TEXT NOT NULL,
                     team TEXT NOT NULL,
	             player TEXT NOT NULL,
	             hero TEXT NOT NULL,
	             stat_name TEXT NOT NULL,
                     stat_amount NUMERIC,
		     PRIMARY KEY (game_id, team, player, hero, stat_name),
		     FOREIGN KEY (game_id) REFERENCES game(game_id),
		     FOREIGN KEY (hero) REFERENCES hero(name)
		     );
		     
	 INSERT INTO player_stat_new SELECT * FROM player_stat;
          DROP TABLE player_stat;
         ALTER TABLE player_stat_new RENAME TO player_stat;

                     COMMIT;

              PRAGMA foreign_keys = ON;

--Drops all redundant tables
          DROP TABLE IF EXISTS match_map_stats;
	  DROP TABLE IF EXISTS player_stat;
	  DROP TABLE IF EXISTS phs_2018_stage_1;
	  DROP TABLE IF EXISTS phs_2018_stage_2;
	  DROP TABLE IF EXISTS phs_2018_stage_3;
	  DROP TABLE IF EXISTS phs_2018_stage_4;
	  DROP TABLE IF EXISTS phs_2018_playoffs;
	  DROP TABLE IF EXISTS phs_2019_stage_1;
	  DROP TABLE IF EXISTS phs_2019_stage_2;
	  DROP TABLE IF EXISTS phs_2019_stage_3;
	  DROP TABLE IF EXISTS phs_2019_stage_4;
	  DROP TABLE IF EXISTS phs_2019_playoffs;
	  DROP TABLE IF EXISTS phs_2020_1;
	  DROP TABLE IF EXISTS phs_2020_2;
	  DROP TABLE IF EXISTS phs_2021_1;
