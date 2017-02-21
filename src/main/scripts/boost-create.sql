-------------
-- Cohorts --
-------------

create table cohorts (
    student         bigint not null,    -- student id
    course          varchar(255),       -- course code
    term            integer,            -- term
    year            integer,            -- year
    grade_symbol    varchar(255),       -- grade symbol
    grade_value     double precision    -- grade value
);

-- We define a cohort as the group of students who took a certain course in the
-- same term or year.
create or replace function cohort( p_course varchar ) returns void as $$
begin
	-- clear the cohort
    delete from cohorts where course = p_course;
    -- select the students and the term and grades when they first took the class
    insert into cohorts select id, code, term, year, symbol, value  from (
        select u.id, c.code, s.term, s.term/10+1900 as year, g.symbol, g.value,
            rank() over (partition by u.id order by s.term) as pos
            from users u
            inner join enrollments e on u.id = e.student_id
            inner join grades g on g.id = e.grade_id
            inner join sections s on s.id = e.section_id
            inner join courses c on c.id = s.course_id
            where c.code = p_course
            order by id, term
        ) as t
        where pos = 1;
    -- delete the ones who only took the given course but no other courses as
    -- these students are probably not CS students
    delete from cohorts h where h.course = p_course and (
        select count(distinct c.id)
            from courses c, sections s, enrollments e
            where c.id = s.course_id and s.id = e.section_id
            and e.student_id = h.student
        ) = 1;
    -- delete the graduate students who took the given course as prerequites.
    -- these are the students who had any G standing but never any B standing.
    delete from cohorts c where
        not exists (
            select * from academic_standings a, standings s
                where a.student_id = c.student
                and a.standing_id = s.id and s.symbol like 'B%'
        ) and exists (
            select * from academic_standings a, standings s
                where a.student_id = c.student
                and a.standing_id = s.id and s.symbol like 'G%'
        );
end;
$$ language plpgsql;

select cohort('CS101');
select cohort('CS120');
select cohort('CS122');
select cohort('CS201');

---------------
-- Graduates --
---------------

create table graduates (
    student         bigint not null,    -- student id
    course          varchar(255),       -- course code
    term            integer,            -- term
    year            integer,            -- year
    grade_symbol    varchar(255),       -- grade symbol
    grade_value     double precision    -- grade value
);

-- We define a "graduate" as a student who took a capstone course like CS490
-- or CS491AB.
create or replace function graduate( p_course varchar ) returns void as $$
begin
	-- clear the cohort
    delete from graduates where course = p_course;
    -- select the students and the term and grades when they first took the class.
    insert into graduates select id, code, term, year, symbol, value  from (
        select u.id, c.code, s.term, s.term/10+1900 as year, g.symbol, g.value,
            rank() over (partition by u.id order by s.term) as pos
            from users u
            inner join enrollments e on u.id = e.student_id
            inner join grades g on g.id = e.grade_id
            inner join sections s on s.id = e.section_id
            inner join courses c on c.id = s.course_id
            where c.code = p_course
            order by id, term
        ) as t
    where pos = 1;
    -- delete the graduate students who took the class as prerequites. these
    -- are the students who had any G standing but never any B standing.
    delete from graduates g where
        not exists (
            select * from academic_standings a, standings s
                where a.student_id = g.student
                and a.standing_id = s.id and s.symbol like 'B%'
        ) and exists (
            select * from academic_standings a, standings s
                where a.student_id = g.student
                and a.standing_id = s.id and s.symbol like 'G%'
        );
end;
$$ language plpgsql;

select graduate('CS490');
select graduate('CS491A');
select graduate('CS496A');

-------------
-- Records --
-------------

create table records  (
    student         bigint not null,    -- student id
    course          varchar(255),       -- course code
    term            integer,            -- term
    year            integer,            -- year
    grade_symbol    varchar(255),       -- grade symbol
    grade_value     double precision    -- grade value
);

insert into records select student, code, term, year, symbol, value  from (
    select student, c.code, s.term, s.term/10+1900 as year, g.symbol, g.value,
        rank() over (partition by student, code, term order by term desc) as pos
        from (select distinct student from cohorts) as h
        inner join enrollments e on h.student = e.student_id
        inner join grades g on g.id = e.grade_id
        inner join sections s on s.id = e.section_id
        inner join courses c on c.id = s.course_id
        order by student, term
    ) as t
    where pos = 1;

delete from records where student = 1007;
update records set grade_value = 0 where grade_symbol = 'NC'
    or grade_symbol = 'W' or grade_symbol = 'I';
update records set grade_value = 3 where grade_symbol = 'CR';
