        
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
