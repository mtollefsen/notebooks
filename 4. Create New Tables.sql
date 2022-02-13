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
