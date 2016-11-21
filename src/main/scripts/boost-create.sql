-- These are our "cohorts", defined as the groups of students who took a
-- certain course in the same term or year.

create table cohorts (
    student         bigint not null,    -- student id
    course          varchar(255),       -- course code
    term            integer,            -- term
    year            integer,            -- year
    grade_symbol    varchar(255),       -- grade symbol
    grade_value     double precision    -- grade value
);

-- Select the students and the term and grades when they first took CS201.

insert into cohorts select id, code, term, year, symbol, value  from (
    select u.id, c.code, s.term, s.term/10+1900 as year, g.symbol,
        coalesce(g.value,0) as value,
        rank() over (partition by u.id order by s.term) as pos
        from users u
        inner join enrollments e on u.id = e.student_id
        inner join grades g on g.id = e.grade_id
        inner join sections s on s.id = e.section_id
        inner join courses c on c.id = s.course_id
        where c.code = 'CS201'
        order by id, term
    ) as t
    where pos = 1;

-- Delete the students who only took CS201 but no other course because these
-- students were probably not CS students.

delete from cohorts c where
    (select count(*) from enrollments e where e.student_id = c.student) = 1;

-- Delete the graduate students who took CS201 as prerequites. These are the
-- students who had any G standing but never any B standing.

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

-- These are our "graduates", defined as the groups of students who took CS490
-- in the same term or year.

create table graduates (
    student         bigint not null,    -- student id
    course          varchar(255),       -- course code
    term            integer,            -- term
    year            integer,            -- year
    grade_symbol    varchar(255),       -- grade symbol
    grade_value     double precision    -- grade value
);

-- Select the students and the term and grades when they first took CS490.

insert into graduates select id, code, term, year, symbol, value  from (
    select u.id, c.code, s.term, s.term/10+1900 as year, g.symbol,
        coalesce(g.value,0) as value,
        rank() over (partition by u.id order by s.term) as pos
        from users u
        inner join enrollments e on u.id = e.student_id
        inner join grades g on g.id = e.grade_id
        inner join sections s on s.id = e.section_id
        inner join courses c on c.id = s.course_id
        where c.code = 'CS490'
        order by id, term
    ) as t
    where pos = 1;

-- Delete the graduate students who took CS201 as prerequites. These are the
-- students who had any G standing but never any B standing.

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
