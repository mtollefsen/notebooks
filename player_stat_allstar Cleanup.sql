
-- Puts the name of each event in stage
    UPDATE player_stat_allstar
       SET stage = 'Genji Skills Challenge'
     WHERE team IN ('Profit', 'Jinmu', 'Sp9rk1e', 'Haksal');
