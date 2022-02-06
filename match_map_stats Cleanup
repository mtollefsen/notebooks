
-- Corrects column misspellings
      ALTER TABLE match_map_stats
           RENAME attacker_control_perecent TO attacker_control_percent;
           
      ALTER TABLE match_map_stats
           RENAME defender_control_perecent TO defender_control_percent;


-- Creates match_loser column
      ALTER TABLE match_map_stats
       ADD COLUMN match_loser AS (CASE
                                     WHEN match_winner = team_one_name THEN team_two_name
                                     ELSE team_one_name
                                  END);


-- Renames "control_round_name" to "map_subsection
      ALTER TABLE match_map_stats
           RENAME control_round_name TO map_subsection;
