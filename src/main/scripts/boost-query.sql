-- This query takes one or more cohort courses and one or more capstone courses,
-- and shows the percentage of the students who eventually reached the capstone
-- courses.
prepare graduation_rate( varchar[], varchar[] ) as
    select c.year as "cohort", count(*) as "all", count(g.student) as "graduated",
        to_char(100.0*count(g.student)/count(c.student), '990D9') as "graduation rate"
        from (select * from cohorts where course = any ($1)) as c
        left join (select * from graduates where course = any ($2)) as g
        on c.student = g.student
        group by c.year
        order by c.year;

-- This query shows how many years on average it took a student to go from
-- a cohort class to a capstone class.
prepare graduation_years( varchar, varchar ) as
    select c.year as "cohort",
        to_char(avg(g.year-c.year), '90D9') as "years to graduation"
        from (select * from cohorts where course = $1) as c
        join (select * from graduates where course = $2) as g
        on c.student = g.student
        group by c.year
        order by c.year;

\echo
\echo 'Graduation Rate from CS101 to CS490:\n'
execute graduation_rate(array['CS101'], array['CS490']);

\echo 'Graduation Rate from CS201 to CS490:\n'
execute graduation_rate(array['CS201'], array['CS490']);

\echo 'Graduation Rate from CS101 to CS491A or CS496A:\n'
execute graduation_rate(array['CS101'], array['CS491A','CS496A']);

\echo 'Graduation Rate from CS201 to CS491A or CS496A:\n'
execute graduation_rate(array['CS201'], array['CS491A','CS496A']);

\echo 'Average Years from CS101 to CS490:\n'
execute graduation_years('CS101','CS490');

\echo 'Average Years from CS201 to CS490:\n'
execute graduation_years('CS201','CS490');
