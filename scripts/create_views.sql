-- Materialized view for monthly lessons in 2024 (Query 1)
CREATE MATERIALIZED VIEW monthly_lessons_2024 AS
SELECT 
    TO_CHAR(lesson_start, 'Mon') AS "Month", 
    COUNT(DISTINCT lesson_id) AS "Total",
    COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='individual') AS "Individual",
    COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='group') AS "Group",
    COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='ensemble') AS "Ensemble"
FROM lessons 
WHERE EXTRACT (YEAR FROM lesson_start) = 2024
GROUP BY 
    TO_CHAR(lesson_start, 'Mon'),
    EXTRACT(MONTH FROM lesson_start) 
ORDER BY 
    EXTRACT(MONTH FROM lesson_start);

CREATE INDEX idx_monthly_lessons_2024_month ON monthly_lessons_2024("Month");

-- Materialized view for the number of students that have a certain number of siblings (Query 2)
CREATE MATERIALIZED VIEW frequency_of_nr_siblings AS
WITH students_per_group AS (
	SELECT sibling_group, 
    COUNT(student_id) AS no_students 
    FROM students
    GROUP BY sibling_group
)
SELECT 
    no_students - 1 AS "Number of siblings",
    COUNT(no_students) * no_students AS "Number of students" 
FROM students_per_group 
GROUP BY no_students ORDER BY no_students;

CREATE INDEX idx_frequency_of_nr_siblings ON frequency_of_nr_siblings("Number of siblings"); 

-- View for number of lessons per instructor (Query 3)
-- Can be used to find instructors that teach more than a certain number of lessons
CREATE VIEW nr_lessons_per_instructor AS
SELECT 
    instructor_id AS "Instructor ID", 
    name AS "Name", 
    COUNT(DISTINCT instructor) AS "Number of lessons" 
FROM instructors 
JOIN lessons ON instructor_id=instructor 
GROUP BY instructor_id 
ORDER BY instructor_id;

CREATE INDEX idx_nr_lessons_per_instructor ON nr_lessons_per_instructor("Instructor ID");

-- Materialized view for the number of open slots in ensemble lessons in week 48 (Query 4)
-- Supporting indexes
CREATE INDEX idx_ensemble_lessons_start ON ensemble_lessons(lesson_start);
CREATE INDEX idx_attendances_lesson ON attendances(lesson);

CREATE MATERIALIZED VIEW open_ensemble_slots AS
WITH booked AS (
	SELECT 
        lesson, 
        COUNT(*) AS attending 
    FROM attendances
    GROUP BY lesson
)
SELECT 
    TO_CHAR(lesson_start, 'YYY-MM-DD') AS "Date",
    EXTRACT(WEEK FROM lesson_start) AS "Week",
    TO_CHAR(lesson_start, 'Day') AS "Day", 
    genre AS "Genre", 
    maximum_students - COALESCE(attending, 0) AS "Nr open slots"
FROM ensemble_lessons 
LEFT JOIN booked ON lesson_id=lesson
ORDER BY lesson_start, "Genre";