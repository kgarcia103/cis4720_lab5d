/* ==========================================================================
   student_practice.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5d

   WHAT THIS FILE IS
   Your working file for Lab 5d. The first two statements are written for
   you. Everything from Step 1 down is yours to write, under the heading
   that is already there for each step.

   HOW TO USE IT
   Run one statement at a time. Put the cursor on it and press Ctrl + E
   twice, or right click and choose Run Current Query. Do not run the whole
   file in one go, because Step 8 creates a function and that step has to be
   run as a single block on its own.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The headings below are already numbered, so keep
   your work underneath the right one. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these two first, in this order
-- =================================================================

-- Every schema on this server. Look for cis_students_db afterwards.
show databases;

-- Make the schema for this lab. IF NOT EXISTS means it is safe to run
-- twice, and it will not complain if you already made it.
create database if not exists cis_students_db;


-- =================================================================
-- POINT YOURSELF AT THE NEW SCHEMA
-- =================================================================

-- Everything below has to land in cis_students_db, not in the schema you
-- connected to. This line switches the session over.
--
-- IMPORTANT: if your tables keep appearing in the wrong place, your tool
-- is opening a new connection for each statement and this line is being
-- forgotten. Step 3 of the lab tells you how to fix that for good by
-- adding a second SQLTools connection that points at cis_students_db.

--we are selecting this databas to work on it
use cis_students_db;


-- ######################################################################
-- YOUR WORK STARTS BELOW THIS LINE
--
-- You write the SQL for Steps 1 through 7 yourself. The handout gives you
-- the specification, the data and the result you should get.
--
-- Steps 8, 9 and 10 are printed in the handout for you to copy, because
-- you have not written a function or a trigger before.
--
-- STEPS 8 AND 10 ARE RUN AT THE COMMAND PROMPT, not in VS Code. They
-- start with DELIMITER, which is an instruction to the command prompt
-- program rather than SQL, so the server rejects it. The handout says
-- what to do. Everything else in this file runs in VS Code as usual.
-- ######################################################################


-- =================================================================
-- STEP 1. Create the students table, then describe it
-- =================================================================

-- create the student table. include auto_increment so that the student_id
--generate a new key using teh counter. assign the sutdent_id as the
-- primaey key
create table if not exists students (
   student_id INT auto_increment primary key,
   first_name VARCHAR(40) not null,
   last_name VARCHAR(40) not null,
   gpa float(4,2)
)
show full tables;
describe students;
-- =================================================================
-- STEP 2. Insert four rows using NULL for student_id and gpa
-- =================================================================

/* insert rows into the students table without having to write
the column names first */

-- insert into students VALUES
--    (NULL, 'Jenna', 'Wilson', NULL),
--    (NULL, 'Robert', 'Reese', NULL),
--    (NULL, 'Maria Elena', 'Jimenez', NULL),
--    (NULL, 'Inder', 'Singh', NULL);
select * from students;

-- =================================================================
-- STEP 3. Insert two more rows, naming the columns first
-- =================================================================

-- insert new rows supplyinh the column name first so that 
--null does not need to be included for the student_id or the 
--gpa

insert into students (first_name, last_name) VALUES
   ('Rita', 'Nunez'),
   ('James', 'Toor');

 select* from students;

-- =================================================================
-- STEP 4. Delete James Toor
-- =================================================================

-- delete james toor student id = 6
delete from students where student_id = 6;


-- =================================================================
-- STEP 5. Create the test_scores table
-- =================================================================

-- create new table scores_table using auto_increment
-- include the student (student_id) as the foreign key

create table if not exists test_scores (
   test_score_id INT auto_increment primary key,
   test_name VARCHAR(20) not null,
   student_id INT not null,
   score float,
   foreign key (student_id) references students(student_id)
);


-- =================================================================
-- STEP 6. Insert the ten test score rows
-- =================================================================

-- insert row into test_scores table 
/*insert into test_scores values
(null,"quiz1", 1, 90),
(null, "quiz2", 4, 91),
(null, "quiz1",  2, 85),
(null, "quiz3", 2, 95),
(null, "quiz1", 3, 95),
(null, "quiz3", 3, 94),
(null, "quiz2",  1, 80),
(null, "quiz3",  4, 74),
(null, "quiz2", 2, 72),
(null, "quiz2", 3, 88)
*/
select * from test_scores;

--select * from students;
-- =================================================================
-- STEP 7. Create the student_scores view from a LEFT OUTER JOIN,
--         then query it twice
-- =================================================================

--write a left outer join so that all of the students
--in the student table display even if they dont have
--any test scores
create view student_scores as
select students.student_id,
concat (first_name, " ", last_name) as student_name,
test_name, score
from students left outer join test_scores
   on students.student_id = test_scores.student_id
   order by students.student_id;

-- =================================================================
-- STEP 8. Create the calculate_gpa function
--
-- Paste the block from the handout in here so it is part of what you
-- submit, then RUN IT AT THE COMMAND PROMPT, not in VS Code.
--
-- DELIMITER is an instruction to the mysql command prompt program. It is
-- not SQL. Run it here and the server rejects it with
--   ERROR 1064 ... near 'DELIMITER $$' at line 1
-- =================================================================

-- name the function and say it takes one argument, a student id
CREATE FUNCTION calculate_gpa(p_student_id INT)
-- the single value it hands back is a number with 2 decimal places
RETURNS DECIMAL(4,2)
-- promise that the same id always produces the same answer
DETERMINISTIC
-- it queries a table but never changes one
READS SQL DATA
-- the body starts here
BEGIN
-- a variable to hold the answer while we work it out
DECLARE v_gpa DECIMAL(4,2);
-- average that student's scores, rounded to 2 decimal places
SELECT ROUND(AVG(score), 2)
-- and put the result into the variable instead of returning it
INTO v_gpa
FROM test_scores
-- only this student's rows
WHERE student_id = p_student_id
-- and ignore any row with no score recorded
AND score IS NOT NULL;
-- hand back the answer. a student with no scores averages to
-- NULL, so IFNULL turns that into 0.00 rather than nothing
RETURN IFNULL(v_gpa, 0.00);
END

show create function calculate_gpa;


-- =================================================================
-- STEP 9. Run the function and fill in every gpa
-- =================================================================

--update the students table using the calculate_gpa
--the calculate_gpa function will update the gpa in the students table
/*update students
set gpa = calculate_gpa(student_id);*/

select * from students;

-- =================================================================
-- STEP 10. Create the triggers that recalculate the gpa
--
-- Same as Step 8. Paste the block in here, then run it at the command
-- prompt. Afterwards add a score or change one, back here in VS Code,
-- and check that the gpa moved on its own.
-- =================================================================

-- create trigger so that when the test_scores table is modified the
--calculate_gpa function runs. we ae not including a delete unstance
--$$ again, because a trigger vody has semicolons in it too
/*
-- fires after a row is ADDED to test_scores
CREATE TRIGGER trg_scores_after_insert
AFTER INSERT ON test_scores
-- once for every row the statement touched, not once per statement
FOR EACH ROW
BEGIN
-- NEW is the row that was just inserted, so NEW.student_id is
-- whichever student that score belongs to
UPDATE students
SET gpa = calculate_gpa(NEW.student_id)
WHERE student_id = NEW.student_id;
END
*/
--and the same again for a score being changed
/*
CREATE TRIGGER trg_scores_after_update
AFTER UPDATE ON test_scores
FOR EACH ROW
BEGIN
UPDATE students
SET gpa = calculate_gpa(NEW.student_id)
WHERE student_id = NEW.student_id;
END*/

show triggers;

--insert row for jenna, student_id =1 in test_scores table

--insert into test_scores values (null, "quiz7", 1, 100);
select * from student_scores where student_id = 1;
select * from students where student_id = 1;


-- =================================================================
-- STEP 11. Push this file to GitHub
-- Nothing to write here. Follow the handout.
-- =================================================================
