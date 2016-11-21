-- This query shows how many students who took CS201 eventually reached the
-- capstone class that we used as the criterion to considered a student
-- graduated.

select c.year as "cohort", count(*) as "all", count(g.student) as "graduated",
    to_char(100.0*count(g.student)/count(c.student), '990D9') as "graduation rate"
    from cohorts c left join graduates g on c.student = g.student
    group by c.year
    order by c.year;

-- This query shows how many years on average it took a student to go from
-- CS201 to the capstone class.

select c.year as "cohort",
    to_char(avg(g.year-c.year), '90D9') as "years to graduation"
    from cohorts c join graduates g on c.student = g.student
    group by c.year
    order by c.year;

