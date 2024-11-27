WITH students_per_group AS (
	SELECT sibling_group, COUNT(student_id) AS no_students FROM students GROUP BY sibling_group
)
SELECT no_students - 1 AS num_of_siblings, COUNT(no_students) * no_students AS num_of_students FROM students_per_group 
GROUP BY no_students ORDER BY no_students;