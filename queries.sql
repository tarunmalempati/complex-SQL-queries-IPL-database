--1--
SELECT player_name FROM player WHERE batting_hand = 'Left-hand bat' and country_name = 'England' ORDER BY player_name;
--2--
SELECT player_name, age AS player_age FROM (SELECT player_id, player_name, DATE_PART('year', age('2018-02-12'::date,dob)) AS age FROM player WHERE bowling_skill='Legbreak googly') AS derived4 WHERE derived4.age >= 28 ORDER BY derived4.age DESC, player_name ASC;
--3--
SELECT match_id, toss_winner FROM match WHERE toss_decision = 'bat' ORDER BY match_id;
--4--
WITH derived4 AS ((SELECT match_id, over_id, ball_id, innings_no, runs_scored AS runs FROM batsman_scored) UNION (SELECT match_id, over_id, ball_id, innings_no, extra_runs AS runs FROM extra_runs) ) SELECT over_id, SUM(runs) AS runs_scored FROM derived4 WHERE match_id = 335987 GROUP BY innings_no, over_id HAVING SUM(runs)<=7 ORDER BY runs_scored DESC, over_id ASC; 
--5--
SELECT player_name FROM player WHERE player_id IN (SELECT DISTINCT player_out FROM wicket_taken WHERE kind_out = 'bowled') ORDER BY player_name; 
--6--
Create table team2 as select * from team; 
Create table team3 as select * from team; 
With derived6 AS(
	SELECT match_id, team_1 AS team_1_id, team_2 AS team_2_id, match_winner, win_margin 
	FROM match 
	WHERE win_type='runs' AND win_margin>=60 ) 
		SELECT derived6.match_id, team.name AS team_1,team2.name AS team_2, team3.name AS winning_team_name, derived6.win_margin 
		FROM derived6,team,team2,team3 
		WHERE derived6.team_1_id = team.team_id AND derived6.team_2_id = team2.team_id AND derived6.match_winner = team3.team_id 
		ORDER BY win_margin, match_id; 
		DROP table team2; 
		DROP table team3;
--7--
SELECT player_name FROM (SELECT player_name, batting_hand, DATE_PART('year', age('2018-02-12'::date,dob)) AS age FROM player) AS derived7 WHERE batting_hand = 'Left-hand bat' and age<30 ORDER BY player_name;
--8--
SELECT derived8_1.match_id AS match_id, (total1 + total2) AS total_runs FROM(SELECT match_id, SUM(runs_scored) AS total1 FROM batsman_scored GROUP BY match_id) AS derived8_1, (SELECT match_id, SUM(extra_runs) AS total2 FROM extra_runs GROUP BY match_id) AS derived8_2 WHERE (derived8_1.match_id = derived8_2.match_id) ORDER BY match_id;
--9--
SELECT match_id, runs_scored AS maximum_runs, player_name FROM player, (WITH derived9_2 AS (WITH derived9_1 AS (WITH derived9 AS ((SELECT match_id, over_id, ball_id, innings_no, runs_scored AS runs FROM batsman_scored) UNION (SELECT match_id, over_id, ball_id, innings_no, extra_runs AS runs FROM extra_runs) ) SELECT match_id, innings_no, over_id, SUM(runs) AS runs_scored FROM derived9 GROUP BY match_id, innings_no, over_id ) SELECT match_id, innings_no, over_id, runs_scored FROM derived9_1 WHERE (match_id, runs_scored) IN (SELECT match_id, MAX(runs_scored) FROM derived9_1 GROUP BY match_id) ORDER BY match_id ) SELECT ball_by_ball.match_id AS match_id, runs_scored, bowler, ball_by_ball.over_id FROM ball_by_ball, derived9_2 WHERE ball_by_ball.match_id = derived9_2.match_id AND ball_by_ball.innings_no = derived9_2.innings_no AND ball_by_ball.over_id = derived9_2.over_id GROUP BY ball_by_ball.match_id, ball_by_ball.innings_no, ball_by_ball.over_id, bowler, runs_scored ) AS derived9_3 WHERE derived9_3.bowler = player.player_id ORDER BY derived9_3.match_id, derived9_3.over_id,player.player_name;
--10--
WITH derived10 AS(SELECT player_out AS player_id, count(kind_out) AS num FROM wicket_taken WHERE kind_out = 'run out'GROUP BY player_out ) SELECT player.player_name AS player_name, derived10_1.num AS number FROM player, ((SELECT player_out AS player_id, count(kind_out) AS num FROM wicket_taken WHERE kind_out = 'run out'GROUP BY player_out ) UNION (SELECT player.player_id, 0 AS num FROM player, derived10 WHERE player.player_id != derived10.player_id ) ) AS derived10_1 WHERE player.player_id = derived10_1.player_id ORDER BY derived10_1.num DESC, player.player_name;
--11--
SELECT kind_out AS out_type, count(kind_out) AS number FROM wicket_taken GROUP BY kind_out ORDER BY number DESC, kind_out ASC;
--12--
WITH derived12_1 AS (SELECT team_id, count(team_id) AS number FROM (SELECT match_id, man_of_the_match FROM match) AS derived12, player_match WHERE player_match.match_id = derived12.match_id AND player_match.player_id = derived12.man_of_the_match GROUP BY team_id ) SELECT team.name AS name, derived12_1.number AS number FROM team, derived12_1 WHERE team.team_id = derived12_1.team_id ORDER BY team.name;
--13--
WITH derived13_1 AS (SELECT match.venue AS venue, sum(derived13.num) AS max_num FROM match, (SELECT match_id, count(extra_type) AS num FROM extra_runs WHERE extra_type = 'wides'GROUP BY match_id) AS derived13 WHERE match.match_id = derived13.match_id GROUP BY match.venue ORDER BY max_num DESC, venue ASC ) SELECT venue FROM derived13_1 WHERE max_num = (SELECT max(max_num) FROM derived13_1) LIMIT 1;
--14-- 
WITH derived14_1 AS ((SELECT match_id, team_1 AS team FROM match WHERE toss_decision = 'bat' AND toss_winner!=team_1 ) UNION (SELECT match_id, team_2 AS team FROM match WHERE toss_decision = 'bat' AND toss_winner!=team_2 ) UNION (SELECT match_id, toss_winner AS team FROM match WHERE toss_decision = 'field') ) SELECT venue FROM match, derived14_1 WHERE match.match_id = derived14_1.match_id AND match.match_winner = derived14_1.team GROUP BY venue ORDER BY count(venue) DESC, venue;
--15--
WITH derived15 AS (WITH wickets AS (SELECT bowler, count(bowler) AS wickets_taken FROM ball_by_ball, wicket_taken WHERE ball_by_ball.match_id = wicket_taken.match_id AND ball_by_ball.over_id = wicket_taken.over_id AND ball_by_ball.ball_id = wicket_taken.ball_id AND ball_by_ball.innings_no = wicket_taken.innings_no GROUP BY bowler ), runs_given AS (WITH runs AS((SELECT bowler, sum(extra_runs) AS runs_given FROM ball_by_ball, extra_runs WHERE ball_by_ball.match_id = extra_runs.match_id AND ball_by_ball.over_id = extra_runs.over_id AND ball_by_ball.ball_id = extra_runs.ball_id AND ball_by_ball.innings_no = extra_runs.innings_no GROUP BY bowler ) UNION (SELECT bowler, sum(runs_scored) AS runs_given FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no GROUP BY bowler )) SELECT bowler, sum(runs_given) AS runs_given FROM runs GROUP BY bowler ) SELECT wickets.bowler AS player_id, ROUND(runs_given.runs_given/wickets.wickets_taken::numeric,3) AS bowling_avg FROM wickets JOIN runs_given ON wickets.bowler = runs_given.bowler ORDER BY bowling_avg ) SELECT player_name FROM player, derived15 WHERE player.player_id = derived15.player_id AND derived15.bowling_avg = (SELECT MIN(bowling_avg) FROM derived15) ORDER BY player_name;
--16--
WITH derived16 AS (SELECT player_id, team_id FROM match, player_match WHERE match.match_id = player_match.match_id AND match.match_winner = player_match.team_id AND player_match.role = 'CaptainKeeper') SELECT DISTINCT player_name, name FROM player, team, derived16 WHERE player.player_id = derived16.player_id AND team.team_id = derived16.team_id ORDER BY player_name,name; 
--17-- 
WITH fifty_scorers AS (WITH derived17_1 AS (SELECT ball_by_ball.match_id, ball_by_ball.over_id, ball_by_ball.ball_id, ball_by_ball.innings_no, striker, runs_scored AS runs FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no ), SELECT DISTINCT striker AS player_id FROM derived17_1 WHERE sum(runs) > 50 GROUP BY match_id,striker ), total_runs AS (WITH derived17_2 AS (SELECT ball_by_ball.match_id, ball_by_ball.over_id, ball_by_ball.ball_id, ball_by_ball.innings_no, striker, runs_scored AS runs FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no ) SELECT striker AS player_id, sum(runs) AS runs_scored FROM derived17_2 GROUP BY striker ) SELECT total_runs.player_id, total_runs.runs_scored FROM fifty_scores, total_runs WHERE total_runs.player_id=fifty_scores.player_id;
--18--
SELECT DISTINCT player_name FROM player, (WITH derived18_3 AS (WITH derived18_1 AS (WITH derived18 AS ((SELECT ball_by_ball.match_id AS match_id, ball_by_ball.over_id AS over_id, ball_by_ball.ball_id AS ball_id, ball_by_ball.innings_no AS innings_no, striker AS player_id, runs_scored AS runs FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no ) ) SELECT player_id, match_id FROM derived18 GROUP BY player_id, match_id HAVING sum(runs)>=100 ORDER BY match_id ), derived18_2 AS ((SELECT match_id, team_1 AS loser FROM match WHERE match_winner = team_2 ) UNION (SELECT match_id, team_2 AS loser FROM match WHERE match_winner = team_1 ) ) SELECT player_id, derived18_1.match_id ,loser AS team_id FROM derived18_1, derived18_2 WHERE derived18_1.match_id = derived18_2.match_id ) SELECT player_match.player_id AS player_id FROM player_match, derived18_3 WHERE derived18_3.team_id = player_match.team_id AND derived18_3.player_id = player_match.player_id AND derived18_3.match_id = player_match.match_id ) AS derived18_4 WHERE derived18_4.player_id = player.player_id ORDER BY player_name;
--19--
WITH teamLost AS ((SELECT match_id, venue, team_1 AS loser FROM match WHERE match_winner != team_1 ) UNION (SELECT match_id, venue, team_2 AS loser FROM match WHERE match_winner != team_2 ) ) SELECT match_id, venue FROM teamLost WHERE loser = (SELECT team_id FROM team WHERE name = 'Kolkata Knight Riders') ORDER BY match_id;
--20--
SELECT player_name FROM player, (SELECT player_id, round((runs/num_matches::numeric),3) AS batting_avg FROM (WITH derived20 AS (WITH runs_scored AS (SELECT ball_by_ball.match_id AS match_id, ball_by_ball.over_id AS over_id, ball_by_ball.ball_id AS ball_id, ball_by_ball.innings_no AS innings_no, striker AS player_id, runs_scored AS runs FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id IN (SELECT match_id FROM match WHERE season_id=5) AND ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no ) SELECT player_id, match_id, sum(runs) AS total_runs FROM runs_scored GROUP BY player_id, match_id ORDER BY player_id ) SELECT player_id, sum(total_runs) AS runs, count(match_id) AS num_matches FROM derived20 GROUP BY player_id ORDER BY player_id ) AS derived20_1 ORDER BY batting_avg DESC LIMIT 10 ) AS derived20_2 WHERE player.player_id = derived20_2.player_id ORDER BY batting_avg DESC, player_name;
--21--
SELECT country_name FROM (WITH batting_averages AS (SELECT player_id, runs/num_matches::numeric AS batting_avg FROM (WITH derived20 AS (WITH runs_scored AS (SELECT ball_by_ball.match_id AS match_id, ball_by_ball.over_id AS over_id, ball_by_ball.ball_id AS ball_id, ball_by_ball.innings_no AS innings_no, striker AS player_id, runs_scored AS runs FROM ball_by_ball, batsman_scored WHERE ball_by_ball.match_id = batsman_scored.match_id AND ball_by_ball.over_id = batsman_scored.over_id AND ball_by_ball.ball_id = batsman_scored.ball_id AND ball_by_ball.innings_no = batsman_scored.innings_no ) SELECT player_id, match_id, sum(runs) AS total_runs FROM runs_scored GROUP BY player_id, match_id ORDER BY player_id ) SELECT player_id, sum(total_runs) AS runs, count(match_id) AS num_matches FROM derived20 GROUP BY player_id ORDER BY player_id ) AS derived20_1 ORDER BY batting_avg DESC ), num_players AS (SELECT country_name, count(country_name) as num_players FROM player GROUP BY country_name ) SELECT country_name, round((sum(batting_averages.batting_avg)/count(batting_averages.player_id)::numeric),3) AS country_batting_average FROM batting_averages, player WHERE batting_averages.player_id = player.player_id GROUP BY country_name ORDER BY country_batting_average DESC, country_name LIMIT 5 ) AS derived21__;