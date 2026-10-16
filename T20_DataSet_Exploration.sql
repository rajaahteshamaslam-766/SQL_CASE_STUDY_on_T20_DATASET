#Q1. Identify matches played between two specific teams(e.g Pakistan and ) in 2024 New Zeland and their result.

select team1,team2,winner from t20i
where (team1='Pakistan' and team2='New Zealand') or (team1='New Zealand' and team2='Pakistan')
and year(matchdate)=2024;

#Q2. Find the team with the highest number of wins in 2024 and the total matches it won.

select  winner,count(*) as number_of_wins
from t20i
where year(matchdate)=2024
group by winner
order by number_of_wins desc;

# Q3. Find number of win matches of pakistan in 2024.

select winner,count(*) as number_of_wins
from t20i
where winner='Pakistan';

# Q3. Find number of tied and no result matches in 2024.

select "no result" as matches,(
select count(winner) as matches_with_no_result
from t20i
where winner like 'no result%' and year(matchdate)=2024) as count
union all
select "tied" as matches,
(
select count(winner) as tied
from t20i
where winner like 'tied%'and year(matchdate)=2024)as count;

# Q4. Rank the teams on the basis of total number of wins in 2024.

select winner ,count(*) as number_of_wins ,
rank () over (order by count(*) desc) as rank_assigned
from t20i
where year(matchdate)=2024 and winner not in ('tied','draw')
group by winner;

#Q no 4. Which team had the highest average winning margin (in runs), and what was the average margin?

select  winner ,round(avg( substring(margin,1,(locate(' ',margin)- 1)  )),2)as avg_margin from
t20i
where margin like '%runs'
group by winner 
order by avg_margin desc; 

#Q no 4.1. Which team had the highest average winning margin (in wickets), and what was the average margin?
select winner,round(avg(substring(margin,1,locate(' ',margin)-1) ),2)as avg_margin
from t20i
where margin like '%wickets%'
group by winner
order by avg_margin desc;

#Q 4.2 Find average winning margin by runs.

select round(avg( substring(margin,1,(locate(' ',margin)- 1)  )),2)as avg_margin from
t20i
where margin like '%runs'
order by avg_margin desc; 

#Q 4.3 Find average winning margin by wickets.

select round(avg( substring(margin,1,(locate(' ',margin)- 1)  )),2)as avg_margin from
t20i
where margin like '%wickets' 
order by avg_margin desc; 

# Q 5 List all matches where winning margin was greater then the average margin across all matches.
select  winner ,round(avg( substring(margin,1,(locate(' ',margin)- 1)  )),2)as avg_margin from
t20i
where margin like '%runs' or margin like '%wickets'
group by winner 
order by avg_margin desc; 

# Q 6. Find the team with the most wins when chasing a target (wins by wickets)
with RankedWinners as(
select  winner,count(*) as win_by_wickets,
DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking from
t20i
where margin like '%wickets' and winner not in ('tied','no result')
group by winner
order by 2 desc
)
select winner,win_by_wickets
from rankedwinners
where ranking =1;

# Q 6.1. Find the teams with the  wins when chasing a target (wins by wickets)
select  winner,count(*) as win_by_wickets from
t20i
where margin like '%wickets' and winner not in ('tied','no result')
group by winner
order by 2 desc;

#Q no 7 . Head to Head record between two selected teams (e.g England Vs Australia)
select winner,count(*) as win_matches
from t20i
where team1 in ('England','Australia') and team2 in ('England','Australia')
group by winner;
#Method two
#intializing variable
set @teamA='England';
set @teamB='Australia';

select winner ,count(*) from
t20i 
where (Team1=@teamA and Team2=@teamB) or (Team1=@teamB and team2=@teamA)
group by winner;

#Q no 8. Identify the month of 2024 with the highest number of t20  matches played.
with rankedmonth as (
select monthname(matchdate) as month_name,count(winner)as match_Played,
dense_rank() over (order by count(*) desc) as ranking
 from 
t20i
where year(matchdate)=2024
group by month_name)
select month_name,match_Played
from rankedmonth
where ranking=1
;

#Q no 8.1. Identify the number of matches played in each month in year 2024(excluding tied and no result matches).
select monthname(matchdate)as month_name,count(*)as matches_played
from t20i
where year(matchdate)=2024 and winner not in('no result','tied')
group by month_name
order by matches_played desc;

#Q NO 9.For each team how many matches they played in 2024 and their wining percentage.
with cte_playedmatches as (
select team ,count(*) as matches_played
from(
select Team1 as team
from t20i
where year(matchdate)=2024 
union all
select Team2 as team
from t20i
where year(matchdate)=2024) t
group by team),


 cte_winmatches as(
select winner as team,count(*)as win_matches
from t20i
where year(matchdate)=2024 and winner not in ('no result','tied')
group by team)
select m.team,m.matches_played,w.win_matches,round(w.win_matches/m.matches_played*100.0,2 )as win_percentage
from cte_playedmatches m left join cte_winmatches w
on m.team=w.team 
order by win_percentage desc;

#Q no 10. Identify the most successful team at each ground(maximum number of wins).

select winner,ground,count(*)as win_matches_at_ground from  
t20i
where winner not in ('no result','tied')
group by winner,ground
order by win_matches_at_ground desc;