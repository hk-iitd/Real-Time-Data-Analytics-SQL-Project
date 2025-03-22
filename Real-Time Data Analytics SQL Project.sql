create database sql_mentor;
use sql_mentor;

drop table if exists user_submission;
create table user_submission(
	id INT Primary Key,
	user_id bigint,
	question_id INT,
	points INT,
	submitted_at timestamp,
	username Varchar(40)
);

select * from user_submission;

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.

-- Solution

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

select username, count(id) as total_submissions, sum(points) as total_points from user_submission
group by 1
order by 3 desc;

-- Q.2 Calculate the daily average points for each user.

select date_format(submitted_at, '%d-%m') as day, username, avg(points) from user_submission
group by 1,2;

-- Q.3 Find the top 3 users with the most positive submissions for each day.

with daily_submissions
as
(select date_format(submitted_at, '%d-%m') as daily, username,
	count((case
		when points > 0 then 1 else 0
	end)) as pst_cnt 
from user_submission
group by 1,2),
submission_rank
as
(select daily, username, pst_cnt,
dense_rank() over(partition by daily order by pst_cnt) as sub_rank
from daily_submissions)
select * from submission_rank where sub_rank < 4;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

select username, 
sum((case
	when points < 0 then 1 else 0
    end)) as incorrect_submissions
from user_submission
group by 1
order by 2 desc
limit 5;

-- Q.5 Find the top 10 performers for each week.

with top10_ranks
as
(select username, week(submitted_at) as week_no, sum(points),
dense_rank() over(partition by week(submitted_at) order by sum(points) desc) as top10_rank
from user_submission
group by 1,2)
select * from top10_ranks where top10_rank < 10;

