
-- Corrects column misspellings, "perecent" -> "percent"
      ALTER TABLE match_map_stats
           RENAME attacker_control_perecent TO attacker_control_percent;
           
      ALTER TABLE match_map_stats
           RENAME defender_control_perecent TO defender_control_percent;


-- Creates "match_loser" column
      ALTER TABLE match_map_stats
       ADD COLUMN match_loser;

-- Populates "match_loser" column
           UPDATE match_map_stats
              SET match_loser = (CASE
                                     WHEN match_winner = team_one_name THEN team_two_name
                                     ELSE team_one_name
                                  END);

-- Removes columns "team_one_name" and "team_two_name"
      ALTER TABLE match_map_stats
      DROP COLUMN team_one_name;

      ALTER TABLE match_map_stats
      DROP COLUMN team_two_name;


-- Renames "control_round_name" to "map_subsection"
      ALTER TABLE match_map_stats
           RENAME control_round_name TO map_subsection;


-- Corrects map_subsection of match 21352, game 1, round 1
           UPDATE match_map_stats
              SET map_subsection  = "MEKA Base"
            WHERE ROWID = 4065;

-- Creates a best estimate of round_start_time for match 21352, game 1, round 1
           UPDATE match_map_stats
              SET round_start_time = (SELECT datetime((strftime("%s", round_end_time) - 215), "unixepoch")
                                        FROM match_map_stats
                                       WHERE ROWID = 4065)
            WHERE ROWID = 4065;
 
-- Deletes a duplicate row with incorrect round_start_time
      DELETE FROM match_map_stats
            WHERE ROWID = 4066
