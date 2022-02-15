
/*
This is a WORK IN PROGRESS to add a round_length
column to match_map_stats. The main obstacle is
ensuring the round_length times are correct as
midmatch pauses can inflate the times and figuring
out the correct time is (currently) a tedious process.
*/

       ALTER TABLE match_map_stats
        ADD COLUMN round_length;

            UPDATE match_map_stats
               SET round_length = (strftime("%s", round_end_time) - strftime("%s", round_start_time));
               
               
--Each query corrects the round_length time of a row 
--(correct time was determined by checking game footage)
--NOTE: the inflated round_length times are primarily 
--due to long pauses that occurred midmatch
            UPDATE match_map_stats
               SET round_length = 443
             WHERE ROWID = 8033;
	     
	    UPDATE match_map_stats
               SET round_length = 291
             WHERE ROWID = 7092;
	     
	    UPDATE match_map_stats
               SET round_length = 263
             WHERE ROWID = 7597;
	     
	    UPDATE match_map_stats
               SET round_length = 514
             WHERE ROWID = 6327;
	     
	    UPDATE match_map_stats
               SET round_length = 329
             WHERE ROWID = 9626;
	     
	    UPDATE match_map_stats
               SET round_length = 347
             WHERE ROWID = 10006;
	     
	    UPDATE match_map_stats
               SET round_length = 396
             WHERE ROWID = 7506;
	     
	    UPDATE match_map_stats
               SET round_length = 498
             WHERE ROWID = 7174;
	     
	    UPDATE match_map_stats
               SET round_length = 200
             WHERE ROWID = 7664;
	     
	    UPDATE match_map_stats
               SET round_length = 341
             WHERE ROWID = 8005;
	     
	    UPDATE match_map_stats
               SET round_length = 500
             WHERE ROWID = 6328;

            UPDATE match_map_stats
               SET round_length = 450
             WHERE ROWID = 8447;
	     
	    UPDATE match_map_stats
               SET round_length = 496
             WHERE ROWID = 5957;
	     
	    UPDATE match_map_stats
               SET round_length = 425
             WHERE ROWID = 10541;
	     
	    UPDATE match_map_stats
               SET round_length = 446
             WHERE ROWID = 10729;

            UPDATE match_map_stats
               SET round_length = 426
             WHERE ROWID = 2724;
	     
	    UPDATE match_map_stats
               SET round_length = 533
             WHERE ROWID = 489;

            UPDATE match_map_stats
               SET round_length = 459
             WHERE ROWID = 8017;
	     
	    UPDATE match_map_stats
               SET round_length = 402
             WHERE ROWID = 9764;
	     
	    UPDATE match_map_stats
               SET round_length = 501
             WHERE ROWID = 9157;

            UPDATE match_map_stats
               SET round_length = 550
             WHERE ROWID = 7206;
	     
	    UPDATE match_map_stats
               SET round_length = 467
             WHERE ROWID = 6263;
	     
	    UPDATE match_map_stats
               SET round_length = 407
             WHERE ROWID = 6523;
	     
	    UPDATE match_map_stats
               SET round_length = 399
             WHERE ROWID = 10582;
	     
	    UPDATE match_map_stats
               SET round_length = 235
             WHERE ROWID = 6579;
